require('dotenv').config();
const bookService = require('../src/services/bookService');

const sampleBooks = [
  {
    title: 'The Alchemist',
    author: 'Paulo Coelho',
    isbn: '9780061122415',
    genre: 'Fiction',
    price: 14.99,
    quantity: 12,
    description: 'A magical fable about following your dream and listening to your heart.',
    publisher: 'HarperOne',
    publishedDate: '1993-04-25T00:00:00.000Z'
  },
  {
    title: 'Clean Code',
    author: 'Robert C. Martin',
    isbn: '9780132350884',
    genre: 'Technology',
    price: 34.50,
    quantity: 8,
    description: 'A handbook of agile software craftsmanship and best programming practices.',
    publisher: 'Prentice Hall',
    publishedDate: '2008-08-01T00:00:00.000Z'
  },
  {
    title: 'Atomic Habits',
    author: 'James Clear',
    isbn: '9780735211292',
    genre: 'Self-Help',
    price: 18.00,
    quantity: 25,
    description: 'An easy and proven way to build good habits and break bad ones.',
    publisher: 'Avery',
    publishedDate: '2018-10-16T00:00:00.000Z'
  },
  {
    title: 'The Pragmatic Programmer',
    author: 'David Thomas, Andrew Hunt',
    isbn: '9780135957059',
    genre: 'Technology',
    price: 39.99,
    quantity: 10,
    description: 'Your journey to mastery in software development and software craft.',
    publisher: 'Addison-Wesley',
    publishedDate: '2019-09-13T00:00:00.000Z'
  },
  {
    title: 'To Kill a Mockingbird',
    author: 'Harper Lee',
    isbn: '9780060935467',
    genre: 'Classic',
    price: 12.95,
    quantity: 15,
    description: 'The unforgettable novel of a childhood in a sleepy Southern town and the crisis of conscience that rocked it.',
    publisher: 'Harper Perennial',
    publishedDate: '1960-07-11T00:00:00.000Z'
  }
];

async function seed() {
  console.log('--- Seeding Books Database ---');
  let inserted = 0;
  let skipped = 0;

  for (const bookData of sampleBooks) {
    try {
      await bookService.createBook(bookData);
      console.log(`[+] Added: "${bookData.title}" (${bookData.isbn})`);
      inserted++;
    } catch (err) {
      if (err.statusCode === 409) {
        console.log(`[-] Skipped (already exists): "${bookData.title}" (${bookData.isbn})`);
        skipped++;
      } else {
        console.error(`[!] Error inserting "${bookData.title}":`, err.message);
      }
    }
  }

  console.log(`--- Seeding Finished: ${inserted} inserted, ${skipped} skipped ---`);
}

seed()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('Seed fatal error:', err);
    process.exit(1);
  });
