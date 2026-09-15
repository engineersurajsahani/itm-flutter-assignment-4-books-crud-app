const REQUIRED_FIELDS = ["title", "author"];
const OPTIONAL_STRING_FIELDS = ["isbn", "genre", "description", "publisher"];
const OPTIONAL_NUMBER_FIELDS = ["price", "quantity"];

function normalizeBookPayload(payload, { partial = false } = {}) {
  if (!payload || typeof payload !== "object" || Array.isArray(payload)) {
    const error = new Error("Request body must be a JSON object.");
    error.status = 400;
    throw error;
  }

  const normalized = {};

  for (const field of REQUIRED_FIELDS) {
    if (!partial || field in payload) {
      const value = typeof payload[field] === "string" ? payload[field].trim() : "";
      if (!value) {
        const error = new Error(`${field} is required.`);
        error.status = 400;
        throw error;
      }
      normalized[field] = value;
    }
  }

  for (const field of OPTIONAL_STRING_FIELDS) {
    if (field in payload) {
      normalized[field] = payload[field] == null ? "" : String(payload[field]).trim();
    }
  }

  for (const field of OPTIONAL_NUMBER_FIELDS) {
    if (field in payload) {
      const value = Number(payload[field]);
      if (Number.isNaN(value)) {
        const error = new Error(`${field} must be a valid number.`);
        error.status = 400;
        throw error;
      }
      normalized[field] = value;
    }
  }

  if ("publishedDate" in payload) {
    const publishedDate = new Date(payload.publishedDate);
    if (Number.isNaN(publishedDate.getTime())) {
      const error = new Error("publishedDate must be a valid date.");
      error.status = 400;
      throw error;
    }
    normalized.publishedDate = publishedDate.toISOString();
  }

  if (partial && Object.keys(normalized).length === 0) {
    const error = new Error("Provide at least one field to update.");
    error.status = 400;
    throw error;
  }

  return normalized;
}

function serializeBook(doc) {
  const data = doc.data();
  return {
    id: doc.id,
    title: data.title || "",
    author: data.author || "",
    isbn: data.isbn || "",
    genre: data.genre || "",
    price: typeof data.price === "number" ? data.price : 0,
    quantity: typeof data.quantity === "number" ? data.quantity : 0,
    description: data.description || "",
    publisher: data.publisher || "",
    publishedDate: data.publishedDate || null,
    createdAt: data.createdAt || null,
    updatedAt: data.updatedAt || null,
  };
}

module.exports = {
  normalizeBookPayload,
  serializeBook,
};
