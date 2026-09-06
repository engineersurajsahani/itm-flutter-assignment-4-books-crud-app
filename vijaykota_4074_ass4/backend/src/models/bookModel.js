class Book {
    constructor(id, title, author, isbn, genre, price, quantity, description, publisher, publishedDate) {
        this.id = id;
        this.title = title;
        this.author = author;
        this.isbn = isbn;
        this.genre = genre;
        this.price = price;
        this.quantity = quantity;
        this.description = description;
        this.publisher = publisher;
        this.publishedDate = publishedDate;
    }
}

module.exports = Book;
