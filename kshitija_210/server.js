require("dotenv").config();

const express = require("express");
const cors = require("cors");

const bookRoutes = require("./src/routes/bookRoutes");

const app = express();
const port = Number(process.env.PORT) || 5001;

app.use(cors());
app.use(express.json());

app.get("/", (_req, res) => {
  res.json({
    message: "Books CRUD backend is running",
    baseUrl: "/api/books",
  });
});

app.use("/api/books", bookRoutes);

app.use((err, _req, res, _next) => {
  const status = err.status || 500;
  res.status(status).json({
    message: err.message || "Internal server error",
  });
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
