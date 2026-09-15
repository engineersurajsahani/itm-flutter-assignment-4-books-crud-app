/**
 * Book Model
 * Data representation and formatting for Book documents
 */
class Book {
  constructor({
    id,
    title,
    author,
    isbn,
    genre,
    price,
    quantity,
    description = '',
    publisher = '',
    publishedDate,
    createdAt,
    updatedAt
  }) {
    this.id = id;
    this.title = title ? title.trim() : '';
    this.author = author ? author.trim() : '';
    this.isbn = isbn ? isbn.trim() : '';
    this.genre = genre ? genre.trim() : '';
    this.price = typeof price === 'number' ? price : parseFloat(price) || 0;
    this.quantity = typeof quantity === 'number' ? quantity : parseInt(quantity, 10) || 0;
    this.description = description ? description.trim() : '';
    this.publisher = publisher ? publisher.trim() : '';
    this.publishedDate = publishedDate instanceof Date 
      ? publishedDate.toISOString() 
      : new Date(publishedDate).toISOString();
    this.createdAt = createdAt || new Date().toISOString();
    this.updatedAt = updatedAt || new Date().toISOString();
  }

  /**
   * Convert to Firestore document data (omitting id)
   */
  toFirestore() {
    return {
      title: this.title,
      author: this.author,
      isbn: this.isbn,
      genre: this.genre,
      price: this.price,
      quantity: this.quantity,
      description: this.description,
      publisher: this.publisher,
      publishedDate: this.publishedDate,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt
    };
  }

  /**
   * Create Book instance from Firestore document snapshot
   */
  static fromFirestore(doc) {
    const data = doc.data();
    return new Book({
      id: doc.id,
      title: data.title,
      author: data.author,
      isbn: data.isbn,
      genre: data.genre,
      price: data.price,
      quantity: data.quantity,
      description: data.description,
      publisher: data.publisher,
      publishedDate: data.publishedDate,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt
    });
  }

  /**
   * Standard JSON serialization
   */
  toJSON() {
    return {
      id: this.id,
      title: this.title,
      author: this.author,
      isbn: this.isbn,
      genre: this.genre,
      price: this.price,
      quantity: this.quantity,
      description: this.description,
      publisher: this.publisher,
      publishedDate: this.publishedDate,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt
    };
  }
}

module.exports = Book;
