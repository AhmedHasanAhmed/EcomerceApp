import Product from "../model/Product.js";

// ➕ Create Product
export const createProduct = async (req, res) => {
  try {
    const { name, price, countInStock, description, image, category } = req.body;

    if (!name || !price || !description || !category) {
      return res.status(400).json({ message: "All required fields must be filled" });
    }

    const product = await Product.create({
      name,
      price,
      stock: countInStock || 0,
      description,
      images: image ? [image] : [],
      categoryId: category,
    });

    res.status(201).json(product);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// 📥 Get All Products
export const getProducts = async (req, res) => {
  try {
    const products = await Product.find().populate("categoryId", "name");
    res.json(products);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// 📥 Get Single Product
export const getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id).populate(
      "categoryId",
      "name"
    );

    if (!product)
      return res.status(404).json({ message: "Product not found" });

    res.json(product);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ✏️ Update Product
export const updateProduct = async (req, res) => {
  try {
    const product = await Product.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );

    if (!product)
      return res.status(404).json({ message: "Product not found" });

    res.json(product);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// 🗑️ Delete Product
export const deleteProduct = async (req, res) => {
  try {
    const product = await Product.findByIdAndDelete(req.params.id);

    if (!product)
      return res.status(404).json({ message: "Product not found" });

    res.json({ message: "Product deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
// 🔍 Search Products
export const searchProducts = async (req, res) => {
  try {
    const { query } = req.query;
    if (!query) return res.json([]);

    const products = await Product.find({
      name: { $regex: query.toString(), $options: "i" },
    }).populate("categoryId", "name");
    res.json(products);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
