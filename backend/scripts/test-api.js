/**
 * Automated REST API Test Suite for Books CRUD API
 */
const http = require('http');
const app = require('../src/app');

function makeRequest(server, { method, path, body }) {
  return new Promise((resolve, reject) => {
    const address = server.address();
    const port = address.port;

    const postData = body ? JSON.stringify(body) : null;
    const options = {
      hostname: '127.0.0.1',
      port,
      path,
      method,
      headers: {
        'Content-Type': 'application/json',
        ...(postData ? { 'Content-Length': Buffer.byteLength(postData) } : {})
      }
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          const parsed = data ? JSON.parse(data) : null;
          resolve({ status: res.statusCode, body: parsed });
        } catch (e) {
          resolve({ status: res.statusCode, raw: data });
        }
      });
    });

    req.on('error', reject);

    if (postData) {
      req.write(postData);
    }
    req.end();
  });
}

async function runTests() {
  console.log('====================================================');
  console.log(' Starting Automated Books CRUD REST API Test Suite');
  console.log('====================================================\n');

  // Start test server on random free port (0)
  const server = await new Promise((resolve) => {
    const s = app.listen(0, () => resolve(s));
  });

  let passed = 0;
  let failed = 0;

  function assert(condition, testName, details = '') {
    if (condition) {
      console.log(`  PASS: ${testName}`);
      passed++;
    } else {
      console.error(`  FAIL: ${testName} ${details ? '- ' + details : ''}`);
      failed++;
    }
  }

  try {
    // 1. Health check
    const health = await makeRequest(server, { method: 'GET', path: '/api/health' });
    assert(health.status === 200 && health.body.success === true, 'GET /api/health returns 200');

    // 2. GET all books
    const initialGet = await makeRequest(server, { method: 'GET', path: '/api/books' });
    assert(initialGet.status === 200 && Array.isArray(initialGet.body.data), 'GET /api/books returns 200 and array');

    // 3. POST valid book
    const testIsbn = '978-0-123456-78-9';
    const newBookPayload = {
      title: 'Design Patterns',
      author: 'Erich Gamma, Richard Helm',
      isbn: testIsbn,
      genre: 'Computer Science',
      price: 49.99,
      quantity: 5,
      description: 'Elements of Reusable Object-Oriented Software',
      publisher: 'Addison-Wesley',
      publishedDate: '1994-10-21T00:00:00.000Z'
    };
    const createRes = await makeRequest(server, {
      method: 'POST',
      path: '/api/books',
      body: newBookPayload
    });
    assert(createRes.status === 201 && createRes.body.success === true && createRes.body.data.id, 'POST /api/books creates book (201)');
    const createdId = createRes.body.data ? createRes.body.data.id : null;

    // 4. Duplicate ISBN should return 409
    const duplicateIsbnRes = await makeRequest(server, {
      method: 'POST',
      path: '/api/books',
      body: { ...newBookPayload, title: 'Another Title' }
    });
    assert(duplicateIsbnRes.status === 409 && duplicateIsbnRes.body.success === false, 'POST /api/books rejects duplicate ISBN with 409 Conflict');

    // 5. Validation failure: missing title should return 400
    const missingTitleRes = await makeRequest(server, {
      method: 'POST',
      path: '/api/books',
      body: { ...newBookPayload, title: '', isbn: '978-9-999999-99-9' }
    });
    assert(missingTitleRes.status === 400 && missingTitleRes.body.success === false, 'POST /api/books validation error on empty title returns 400');

    // 6. Validation failure: negative price should return 400
    const negativePriceRes = await makeRequest(server, {
      method: 'POST',
      path: '/api/books',
      body: { ...newBookPayload, price: -5, isbn: '978-9-999999-99-8' }
    });
    assert(negativePriceRes.status === 400 && negativePriceRes.body.success === false, 'POST /api/books validation error on negative price returns 400');

    // 7. GET single book by ID
    const getSingleRes = await makeRequest(server, {
      method: 'GET',
      path: `/api/books/${createdId}`
    });
    assert(getSingleRes.status === 200 && getSingleRes.body.data.title === 'Design Patterns', 'GET /api/books/:id returns 200 with book details');

    // 8. GET non-existent book ID should return 404
    const getNotFoundRes = await makeRequest(server, {
      method: 'GET',
      path: '/api/books/nonexistent-id-999'
    });
    assert(getNotFoundRes.status === 404 && getNotFoundRes.body.success === false, 'GET /api/books/:id for missing book returns 404');

    // 9. PUT update book
    const updateRes = await makeRequest(server, {
      method: 'PUT',
      path: `/api/books/${createdId}`,
      body: {
        ...newBookPayload,
        title: 'Design Patterns: Elements of Reusable OO Software (Updated)',
        price: 54.99,
        quantity: 7
      }
    });
    assert(updateRes.status === 200 && updateRes.body.data.price === 54.99, 'PUT /api/books/:id successfully updates book (200)');

    // 10. PUT non-existent book returns 404
    const updateNotFound = await makeRequest(server, {
      method: 'PUT',
      path: '/api/books/nonexistent-id-999',
      body: newBookPayload
    });
    assert(updateNotFound.status === 404, 'PUT /api/books/:id for non-existent book returns 404');

    // 11. DELETE book
    const deleteRes = await makeRequest(server, {
      method: 'DELETE',
      path: `/api/books/${createdId}`
    });
    assert(deleteRes.status === 200 && deleteRes.body.success === true, 'DELETE /api/books/:id deletes book (200)');

    // 12. Repeat DELETE should return 404
    const deleteRepeatRes = await makeRequest(server, {
      method: 'DELETE',
      path: `/api/books/${createdId}`
    });
    assert(deleteRepeatRes.status === 404, 'DELETE /api/books/:id for already deleted book returns 404');

    // 13. Unknown route returns 404
    const unknownRes = await makeRequest(server, {
      method: 'GET',
      path: '/api/some-unknown-route'
    });
    assert(unknownRes.status === 404 && unknownRes.body.success === false, 'Unknown route returns 404');

  } finally {
    server.close();
  }

  console.log('\n====================================================');
  console.log(` Results: ${passed} passed, ${failed} failed`);
  console.log('====================================================');

  if (failed > 0) {
    process.exit(1);
  }
}

runTests().catch((err) => {
  console.error('Test execution failed:', err);
  process.exit(1);
});
