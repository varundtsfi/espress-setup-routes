require("dotenv").config();
const express = require("express");
const app = express();
// const mongoose = require("mongoose"); // Remove if not used
// const connectDB = require("./db/connection"); // Remove if not used
const PORT = process.env.PORT || 5000;

const products_routes = require("./routes/products");

app.get("/", (req, res) => {
  res.send("Hi, I am live!");
});

app.use("/api/products", products_routes);

const start = async () => {
  // Add 'const' here!
  try {
    // await connectDB(process.env.MONGO_URI);
    app.listen(PORT);
    console.log(`${PORT} Yes I am connected and ${PORT} Server is running.`);
  } catch (error) {
    console.error("Error starting the server:", error);
  }
};
start();
