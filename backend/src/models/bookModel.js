class Book {
  constructor(data) {
    this.title = data.title;
    this.author = data.author;
    this.isbn = data.isbn;
    this.genre = data.genre || '';
    this.price = Number(data.price) || 0;
    this.quantity = Number(data.quantity) || 0;
    this.description = data.description || '';
    this.publisher = data.publisher || '';
    this.publishedDate = data.publishedDate || null;
  }
}

module.exports = Book;