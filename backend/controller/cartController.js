import Cart from "../model/Cart.js";

// ➕ Add item to cart
export const addToCart = async (req, res) => {
  try {
    const { userId, productId, qty } = req.body;

    if (!userId || !productId) {
      return res
        .status(400)
        .json({ message: "userId and productId are required" });
    }

    let cart = await Cart.findOne({ userId });

    // Haddii cart uusan jirin
    if (!cart) {
      cart = await Cart.create({
        userId,
        items: [{ productId, qty: qty || 1 }],
      });
      return res.status(201).json(cart);
    }

    // Haddii product hore ugu jiro cart
    const itemIndex = cart.items.findIndex(
      (item) => item.productId.toString() === productId
    );

    if (itemIndex > -1) {
      cart.items[itemIndex].qty += qty || 1;
    } else {
      cart.items.push({ productId, qty: qty || 1 });
    }

    await cart.save();
    res.json(cart);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// 📥 Get User Cart
export const getCartByUser = async (req, res) => {
  try {
    const cart = await Cart.findOne({ userId: req.params.userId })
      .populate("items.productId", "name price images");

    if (!cart)
      return res.status(404).json({ message: "Cart not found" });

    res.json(cart);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ✏️ Update Item Qty
export const updateCartItem = async (req, res) => {
  try {
    const { qty } = req.body;

    const cart = await Cart.findOne({ userId: req.params.userId });

    if (!cart)
      return res.status(404).json({ message: "Cart not found" });

    const item = cart.items.find(
      (i) => i.productId.toString() === req.params.productId
    );

    if (!item)
      return res.status(404).json({ message: "Item not found in cart" });

    item.qty = qty;
    await cart.save();

    res.json(cart);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// 🗑️ Remove item from cart
export const removeCartItem = async (req, res) => {
  try {
    const cart = await Cart.findOne({ userId: req.params.userId });

    if (!cart)
      return res.status(404).json({ message: "Cart not found" });

    cart.items = cart.items.filter(
      (item) => item.productId.toString() !== req.params.productId
    );

    await cart.save();
    res.json(cart);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// 🧹 Clear Cart
export const clearCart = async (req, res) => {
  try {
    const cart = await Cart.findOne({ userId: req.params.userId });

    if (!cart)
      return res.status(404).json({ message: "Cart not found" });

    cart.items = [];
    await cart.save();

    res.json({ message: "Cart cleared" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
