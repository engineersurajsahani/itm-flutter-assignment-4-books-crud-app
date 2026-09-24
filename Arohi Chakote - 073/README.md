# 📚 Books CRUD Application - Assignment 4

**Student Name:** Arohi Chakote  
**Roll Number:** 073  
**GitHub Username:** arohick11  

---

## 🚀 Overview
This repository contains the solution for **Assignment 4: Books CRUD Application**, a full-stack Flutter + Node.js Express application with Firebase/REST backend support.

## 📱 Features
- **Book List**: Displays all books with live search filtering by title, author, genre, or ISBN.
- **Add Book**: Form with client-side validation, date picker, price & quantity fields.
- **Edit Book**: Pre-populated form allowing instant updates of existing book details.
- **Book Detail**: In-depth view of book information with Edit and Delete capabilities.
- **Delete Confirmation**: Modal confirmation dialog before removing a book.
- **Backend API**: RESTful endpoints (`GET`, `POST`, `PUT`, `DELETE`) with Express.js and Firebase Admin SDK / Fallback Store.

## 🛠️ Instructions to Run

### 1. Start Node.js Backend Server
```bash
cd "Arohi Chakote - 073/backend"
npm install
npm start
```
*The server runs on `http://localhost:5000` (API endpoint: `http://localhost:5000/api/books`).*

### 2. Run Flutter App
```bash
cd "Arohi Chakote - 073"
flutter pub get
flutter run
```
