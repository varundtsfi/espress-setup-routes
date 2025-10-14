const genericController = {
  async getAllProducts(req, res) {
    res.status(200).json({
      success: true,
      message: "All products fetched successfully",
    });
  },

  async getAllProductsTesting(req, res) {
    res.status(200).json({
      success: true,
      message: "All products tested successfully",
    });
  },
};

module.exports = genericController; // Changed from: export { genericController };
