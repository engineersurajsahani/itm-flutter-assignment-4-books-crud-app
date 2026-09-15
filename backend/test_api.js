process.env.NODE_ENV = 'test';
const http = require('http');
const app = require('./server');

const TEST_PORT = 5090;
let server;

function request(options, data) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => (body += chunk));
      res.on('end', () => {
        try {
          const parsed = body ? JSON.parse(body) : {};
          resolve({ status: res.statusCode, headers: res.headers, body: parsed });
        } catch (e) {
          resolve({ status: res.statusCode, headers: res.headers, raw: body });
        }
      });
    });

    req.on('error', reject);

    if (data) {
      req.write(JSON.stringify(data));
    }
    req.end();
  });
}

async function runTests() {
  console.log('🧪 Starting API Verification Tests on port ' + TEST_PORT + '...\n');

  server = app.listen(TEST_PORT);
  let passed = 0;
  let failed = 0;

  function assert(condition, message) {
    if (condition) {
      console.log(`  ✅ PASS: ${message}`);
      passed++;
    } else {
      console.error(`  ❌ FAIL: ${message}`);
      failed++;
    }
  }

  try {
    // 1. Health Check
    console.log('[Test 1] GET /api/health');
    const healthRes = await request({
      hostname: 'localhost',
      port: TEST_PORT,
      path: '/api/health',
      method: 'GET'
    });
    assert(healthRes.status === 200, 'Health check returns status 200');
    assert(healthRes.body.status === 'healthy', 'Health check status is healthy');

    // 2. Create a new Book
    console.log('\n[Test 2] POST /api/books (Create Book)');
    const book1 = {
      title: 'Clean Code',
      author: 'Robert C. Martin',
      isbn: '978-0132350884',
      genre: 'Software Engineering',
      price: 37.99,
      quantity: 15,
      description: 'A handbook of agile software craftsmanship.',
      publisher: 'Prentice Hall',
      publishedDate: '2008-08-01'
    };
    const createRes1 = await request(
      {
        hostname: 'localhost',
        port: TEST_PORT,
        path: '/api/books',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      },
      book1
    );
    assert(createRes1.status === 201, 'POST /api/books returns 201 Created');
    assert(createRes1.body.success === true, 'Response body success is true');
    assert(createRes1.body.data && createRes1.body.data.id !== undefined, 'Returned book has an ID');
    assert(createRes1.body.data.title === 'Clean Code', 'Title matches Clean Code');

    const createdId = createRes1.body.data ? createRes1.body.data.id : null;

    // 3. Duplicate ISBN check
    console.log('\n[Test 3] POST /api/books (Duplicate ISBN Rejection)');
    const duplicateBook = {
      title: 'Clean Code Duplicate',
      author: 'Another Author',
      isbn: '978-0132350884', // Same ISBN
      genre: 'Software',
      price: 25.0
    };
    const dupRes = await request(
      {
        hostname: 'localhost',
        port: TEST_PORT,
        path: '/api/books',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      },
      duplicateBook
    );
    assert(dupRes.status === 409, 'Duplicate ISBN returns 409 Conflict');
    assert(dupRes.body.success === false, 'Duplicate response success is false');

    // 4. Create second book
    console.log('\n[Test 4] POST /api/books (Create Second Book)');
    const book2 = {
      title: 'The Pragmatic Programmer',
      author: 'Andrew Hunt & David Thomas',
      isbn: '978-0201616224',
      genre: 'Software Engineering',
      price: 45.50,
      quantity: 10,
      description: 'Your journey to mastery.',
      publisher: 'Addison-Wesley',
      publishedDate: '1999-10-30'
    };
    const createRes2 = await request(
      {
        hostname: 'localhost',
        port: TEST_PORT,
        path: '/api/books',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      },
      book2
    );
    assert(createRes2.status === 201, 'Second book created with 201 Created');

    // 5. GET All Books
    console.log('\n[Test 5] GET /api/books (Retrieve All Books)');
    const getAllRes = await request({
      hostname: 'localhost',
      port: TEST_PORT,
      path: '/api/books',
      method: 'GET'
    });
    assert(getAllRes.status === 200, 'GET /api/books returns 200 OK');
    assert(getAllRes.body.count >= 2, `Count is ${getAllRes.body.count} (>= 2)`);
    assert(Array.isArray(getAllRes.body.data), 'data is an array');

    // 6. Search Books
    console.log('\n[Test 6] GET /api/books?search=Pragmatic');
    const searchRes = await request({
      hostname: 'localhost',
      port: TEST_PORT,
      path: '/api/books?search=Pragmatic',
      method: 'GET'
    });
    assert(searchRes.status === 200, 'Search returns 200 OK');
    assert(
      searchRes.body.data.length === 1 && searchRes.body.data[0].title.includes('Pragmatic'),
      'Search correctly filtered Pragmatic Programmer'
    );

    // 7. GET Book by ID
    console.log('\n[Test 7] GET /api/books/:id');
    const getByIdRes = await request({
      hostname: 'localhost',
      port: TEST_PORT,
      path: `/api/books/${createdId}`,
      method: 'GET'
    });
    assert(getByIdRes.status === 200, 'GET /api/books/:id returns 200 OK');
    assert(getByIdRes.body.data.id === createdId, 'Returned book ID matches requested ID');

    // 8. UPDATE Book
    console.log('\n[Test 8] PUT /api/books/:id (Update Book)');
    const updatePayload = {
      price: 39.99,
      quantity: 20,
      description: 'Updated description for agile craftsmanship handbook.'
    };
    const updateRes = await request(
      {
        hostname: 'localhost',
        port: TEST_PORT,
        path: `/api/books/${createdId}`,
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' }
      },
      updatePayload
    );
    assert(updateRes.status === 200, 'PUT /api/books/:id returns 200 OK');
    assert(updateRes.body.data.price === 39.99, 'Updated price matches 39.99');
    assert(updateRes.body.data.quantity === 20, 'Updated quantity matches 20');

    // 9. DELETE Book
    console.log('\n[Test 9] DELETE /api/books/:id');
    const deleteRes = await request({
      hostname: 'localhost',
      port: TEST_PORT,
      path: `/api/books/${createdId}`,
      method: 'DELETE'
    });
    assert(deleteRes.status === 200, 'DELETE /api/books/:id returns 200 OK');
    assert(deleteRes.body.success === true, 'Delete response success is true');

    // 10. Verify DELETED book returns 404
    console.log('\n[Test 10] GET /api/books/:id (After Deletion)');
    const getAfterDeleteRes = await request({
      hostname: 'localhost',
      port: TEST_PORT,
      path: `/api/books/${createdId}`,
      method: 'GET'
    });
    assert(getAfterDeleteRes.status === 404, 'Deleted book returns 404 Not Found');

    // 11. Validation error test (Missing title/author)
    console.log('\n[Test 11] POST /api/books (Validation Error - Missing required fields)');
    const invalidBook = {
      price: -10,
      quantity: -5
    };
    const invalidRes = await request(
      {
        hostname: 'localhost',
        port: TEST_PORT,
        path: '/api/books',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      },
      invalidBook
    );
    assert(invalidRes.status === 400, 'Invalid book payload returns 400 Bad Request');
    assert(invalidRes.body.success === false, 'Invalid book response success is false');
    assert(Array.isArray(invalidRes.body.errors), 'Errors is an array with descriptive messages');

    console.log(`\n========================================`);
    console.log(`🎯 Test Summary: ${passed} Passed, ${failed} Failed`);
    console.log(`========================================\n`);

    if (failed > 0) {
      process.exitCode = 1;
    }
  } catch (err) {
    console.error('Fatal test error:', err);
    process.exitCode = 1;
  } finally {
    server.close();
  }
}

runTests();
