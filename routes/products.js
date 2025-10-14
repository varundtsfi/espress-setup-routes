const express = require("express");
const router = express.Router();

const genericController = require("../controllers/products");

router.route("/").get(genericController.getAllProducts);
router.route("/testing").get(genericController.getAllProductsTesting);

module.exports = router;
