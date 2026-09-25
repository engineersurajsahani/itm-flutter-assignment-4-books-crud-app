const express = require('express');
const controller = require('../controllers/bookController');

const router = express.Router();
router.get('/', controller.getBooks);
router.get('/:id', controller.getBook);
router.post('/', controller.createBook);
router.put('/:id', controller.updateBook);
router.delete('/:id', controller.deleteBook);
module.exports = router;
