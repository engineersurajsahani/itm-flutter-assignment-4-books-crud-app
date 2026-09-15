const http = require('http');
const app = require('./server');

const TEST_PORT = 5050;

function makeRequest(options, postData = null) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          resolve({ statusCode: res.statusCode, headers: res.headers, body: parsed });
        } catch (e) {
          resolve({ statusCode: res.statusCode, headers: res.headers, raw: data });
        }
      });
    });

    req.on('error', (err) => {
      reject(err);
    });

    if (postData) {
      req.write(typeof postData === 'string' ? postData : JSON.stringify(postData));
    }
    req.end();
  });
}

async function runTests() {
  const server = app.listen(TEST_PORT, () => {
    console.log(`\n🧪 Test server started on port ${TEST_PORT}\n`);
  });

  let createdBookId = null;

  try {
    console.log('--- Test 1: Health Check (GET /) ---');
    const health = await makeRequest({
      hostname: 'localhost',
      port: TEST_PORT,
      path: '/',
      method: 'GET'
    });
    console.log(`Status: ${health.statusCode}, online: ${health.body.status === 'online'}`);
    if (health.statusCode !== 200) throw new Error('Health check failed');

    console.log('\n--- Test 2: Get All Books (GET /api/books) ---');
    const allBooks = await makeRequest({
      hostname: 'localhost',
      port: TEST_PORT,
      path: '/api/books',
      method: 'GET'
    });
    console.log(`Status: ${allBooks.statusCode}, count: ${allBooks.body.count}`);
    if (allBooks.statusCode !== 200 || !Array.isArray(allBooks.body.data)) throw new Error('Get all books failed');

    console.log('\n--- Test 3: Create Book (POST /api/books) ---');
    const newBookPayload = {
      title: 'Flutter Apprentice',
      author: 'Ray Wenderlich Team',
      isbn: '978-1950325436',
      genre: 'Mobile Development',
      price: 54.99,
      quantity: 25,
      description: 'Beginning Flutter development with Dart',
      publisher: 'Razeware LLC',
      publishedDate: '2021-04-01T00:00:00.000Z'
    };
    const createRes = await makeRequest({
      hostname: 'localhost',
      port: TEST_PORT,
      path: '/api/books',
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    }, newBookPayload);

    console.log(`Status: ${createRes.statusCode}, ID: ${createRes.body.data?.id}`);
    if (createRes.statusCode !== 201 || !createRes.body.data?.id) throw new Error('Create book failed');
    createdBookId = createRes.body.data.id;

    console.log('\n--- Test 4: Duplicate ISBN check (POST /api/books) ---');
    const dupRes = await makeRequest({
      hostname: 'localhost',
      port: TEST_PORT,
      path: '/api/books',
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    }, newBookPayload);
    console.log(`Status: ${dupRes.statusCode}, Message: ${dupRes.body.message}`);
    if (dupRes.statusCode !== 409) throw new Error('Duplicate ISBN check should return 409 Conflict');

    console.log('\n--- Test 5: Validation Error check (POST /api/books with missing fields) ---');
    const invalidRes = await makeRequest({
      hostname: 'localhost',
      port: TEST_PORT,
      path: '/api/books',
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    }, { price: -10 });
    console.log(`Status: ${invalidRes.statusCode}, Errors: ${JSON.stringify(invalidRes.body.errors)}`);
    if (invalidRes.statusCode !== 400) throw new Error('Validation error should return 400');

    console.log(`\n--- Test 6: Get Book by ID (GET /api/books/${createdBookId}) ---`);
    const getRes = await makeRequest({
      hostname: 'localhost',
      port: TEST_PORT,
      path: `/api/books/${createdBookId}`,
      method: 'GET'
    });
    console.log(`Status: ${getRes.statusCode}, Title: ${getRes.body.data?.title}`);
    if (getRes.statusCode !== 200 || getRes.body.data?.id !== createdBookId) throw new Error('Get book by ID failed');

    console.log(`\n--- Test 7: Update Book (PUT /api/books/${createdBookId}) ---`);
    const updateRes = await makeRequest({
      hostname: 'localhost',
      port: TEST_PORT,
      path: `/api/books/${createdBookId}`,
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' }
    }, {
      price: 49.99,
      quantity: 30
    });
    console.log(`Status: ${updateRes.statusCode}, New price: ${updateRes.body.data?.price}, New quantity: ${updateRes.body.data?.quantity}`);
    if (updateRes.statusCode !== 200 || updateRes.body.data?.price !== 49.99) throw new Error('Update book failed');

    console.log('\n--- Test 8: Search Books (GET /api/books?search=Flutter) ---');
    const searchRes = await makeRequest({
      hostname: 'localhost',
      port: TEST_PORT,
      path: '/api/books?search=Flutter',
      method: 'GET'
    });
    console.log(`Status: ${searchRes.statusCode}, Results found: ${searchRes.body.count}`);
    if (searchRes.statusCode !== 200 || searchRes.body.count < 1) throw new Error('Search books failed');

    console.log(`\n--- Test 9: Delete Book (DELETE /api/books/${createdBookId}) ---`);
    const deleteRes = await makeRequest({
      hostname: 'localhost',
      port: TEST_PORT,
      path: `/api/books/${createdBookId}`,
      method: 'DELETE'
    });
    console.log(`Status: ${deleteRes.statusCode}, Message: ${deleteRes.body.message}`);
    if (deleteRes.statusCode !== 200) throw new Error('Delete book failed');

    console.log(`\n--- Test 10: Verify Deletion (GET /api/books/${createdBookId}) ---`);
    const verifyDelete = await makeRequest({
      hostname: 'localhost',
      port: TEST_PORT,
      path: `/api/books/${createdBookId}`,
      method: 'GET'
    });
    console.log(`Status: ${verifyDelete.statusCode}, Message: ${verifyDelete.body.message}`);
    if (verifyDelete.statusCode !== 404) throw new Error('Deleted book should return 404');

    console.log('\n========================================');
    console.log('🎉 ALL 10 TESTS PASSED SUCCESSFULLY! 🎉');
    console.log('========================================\n');
  } catch (err) {
    console.error('❌ Test failed:', err);
    process.exitCode = 1;
  } finally {
    server.close();
  }
}

runTests();
