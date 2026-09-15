const { getDb } = require("../config/firebase");
const { normalizeBookPayload, serializeBook } = require("../models/bookModel");

const COLLECTION = "books";

async function ensureUniqueIsbn(db, isbn, excludeId) {
  if (!isbn) {
    return;
  }

  const snapshot = await db.collection(COLLECTION).where("isbn", "==", isbn).get();
  const duplicate = snapshot.docs.find((doc) => doc.id !== excludeId);

  if (duplicate) {
    const error = new Error("A book with this ISBN already exists.");
    error.status = 409;
    throw error;
  }
}

async function getAllBooks(_req, res, next) {
  try {
    const db = getDb();
    const snapshot = await db.collection(COLLECTION).orderBy("createdAt", "desc").get();
    const books = snapshot.docs.map(serializeBook);
    res.json(books);
  } catch (error) {
    next(error);
  }
}

async function getBookById(req, res, next) {
  try {
    const db = getDb();
    const doc = await db.collection(COLLECTION).doc(req.params.id).get();

    if (!doc.exists) {
      return res.status(404).json({ message: "Book not found." });
    }

    res.json(serializeBook(doc));
  } catch (error) {
    next(error);
  }
}

async function createBook(req, res, next) {
  try {
    const db = getDb();
    const payload = normalizeBookPayload(req.body);
    const now = new Date().toISOString();

    await ensureUniqueIsbn(db, payload.isbn);

    const docRef = await db.collection(COLLECTION).add({
      ...payload,
      createdAt: now,
      updatedAt: now,
    });

    const createdDoc = await docRef.get();
    res.status(201).json(serializeBook(createdDoc));
  } catch (error) {
    next(error);
  }
}

async function updateBook(req, res, next) {
  try {
    const db = getDb();
    const docRef = db.collection(COLLECTION).doc(req.params.id);
    const existingDoc = await docRef.get();

    if (!existingDoc.exists) {
      return res.status(404).json({ message: "Book not found." });
    }

    const payload = normalizeBookPayload(req.body, { partial: true });
    await ensureUniqueIsbn(db, payload.isbn, req.params.id);

    await docRef.update({
      ...payload,
      updatedAt: new Date().toISOString(),
    });

    const updatedDoc = await docRef.get();
    res.json(serializeBook(updatedDoc));
  } catch (error) {
    next(error);
  }
}

async function deleteBook(req, res, next) {
  try {
    const db = getDb();
    const docRef = db.collection(COLLECTION).doc(req.params.id);
    const existingDoc = await docRef.get();

    if (!existingDoc.exists) {
      return res.status(404).json({ message: "Book not found." });
    }

    await docRef.delete();
    res.json({ message: "Book deleted successfully." });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getAllBooks,
  getBookById,
  createBook,
  updateBook,
  deleteBook,
};
