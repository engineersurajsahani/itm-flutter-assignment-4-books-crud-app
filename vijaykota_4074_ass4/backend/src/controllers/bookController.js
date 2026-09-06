const { db } = require('../config/firebase');
const Book = require('../models/bookModel');

// Collection reference
const booksRef = db.collection('books');

// Get all books
const getAllBooks = async (req, res) => {
    try {
        const snapshot = await booksRef.get();
        const books = [];
        snapshot.forEach(doc => {
            books.push({ id: doc.id, ...doc.data() });
        });
        res.status(200).json(books);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get a specific book
const getBook = async (req, res) => {
    try {
        const id = req.params.id;
        const book = await booksRef.doc(id).get();
        if (!book.exists) {
            res.status(404).json({ message: 'Book not found' });
        } else {
            res.status(200).json({ id: book.id, ...book.data() });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Add a new book
const addBook = async (req, res) => {
    try {
        const data = req.body;
        if (!data.title || !data.author) {
            return res.status(400).json({ message: "Title and Author are required." });
        }
        
        // Add to firestore
        const docRef = await booksRef.add(data);
        res.status(201).json({ message: 'Book created successfully', id: docRef.id });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Update a book
const updateBook = async (req, res) => {
    try {
        const id = req.params.id;
        const data = req.body;
        const book = booksRef.doc(id);
        
        // Validate if exists
        const doc = await book.get();
        if (!doc.exists) {
            return res.status(404).json({ message: 'Book not found' });
        }

        await book.update(data);
        res.status(200).json({ message: 'Book updated successfully' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Delete a book
const deleteBook = async (req, res) => {
    try {
        const id = req.params.id;
        const book = booksRef.doc(id);

        const doc = await book.get();
        if (!doc.exists) {
            return res.status(404).json({ message: 'Book not found' });
        }

        await book.delete();
        res.status(200).json({ message: 'Book deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    getAllBooks,
    getBook,
    addBook,
    updateBook,
    deleteBook
};
