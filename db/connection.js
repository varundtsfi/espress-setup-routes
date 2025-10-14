const mongoose = require("mongoose");

const connectDB = (MONGO_URI) => {
  try {
    console.log(`MongoDB Connected successfully.`);
    return mongoose.connect(MONGO_URI);
    //    mongoose.connect(MONGO_URI);

    //     console.log(`MongoDB Connected successfully: ${MONGO_URI}`);
    //     return mongoose.connection;
  } catch (error) {
    console.error(`connectDB Error: ${error.message}`);
    process.exit(1);
  }
};

module.exports = connectDB;
