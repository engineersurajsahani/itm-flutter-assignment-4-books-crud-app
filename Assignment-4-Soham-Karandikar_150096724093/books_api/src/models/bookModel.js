const db = require('../config/firebase');

const collection = () => db.collection('books');

module.exports = { collection };
