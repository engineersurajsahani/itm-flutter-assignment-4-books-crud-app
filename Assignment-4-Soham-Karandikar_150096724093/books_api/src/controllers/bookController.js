const { collection } = require('../models/bookModel');

exports.getBooks = async (req, res) => { const snapshot = await collection().get(); res.json(snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }))); };
exports.getBook = async (req, res) => { const doc = await collection().doc(req.params.id).get(); if (!doc.exists) return res.status(404).json({ error: 'Book not found' }); res.json({ id: doc.id, ...doc.data() }); };
exports.createBook = async (req, res) => { const ref = await collection().add(req.body); res.status(201).json({ id: ref.id, ...req.body }); };
exports.updateBook = async (req, res) => { await collection().doc(req.params.id).set(req.body, { merge: true }); res.json({ id: req.params.id, ...req.body }); };
exports.deleteBook = async (req, res) => { await collection().doc(req.params.id).delete(); res.status(204).send(); };
