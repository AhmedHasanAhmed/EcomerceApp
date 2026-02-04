import Order from "../model/Order.js";
import Cart from "../model/Cart.js";
import Product from "../model/Product.js";
import User from "../model/User.js";

// ➕ Create Order (from cart)
export const createOrder = async (req, res) => {
  try {
    const { userId, shippingAddress, paymentMethod, shippingPrice, taxPrice } = req.body;

    if (!userId || !shippingAddress || !paymentMethod) {
      return res.status(400).json({ message: "userId, address and payment are required" });
    }

    const cart = await Cart.findOne({ userId }).populate("items.productId");

    if (!cart || cart.items.length === 0) {
      return res.status(400).json({ message: "Cart is empty" });
    }

    let itemsPrice = 0;

    const orderItems = cart.items.map((item) => {
      itemsPrice += item.productId.price * item.qty;

      return {
        productId: item.productId._id,
        qty: item.qty,
        price: item.productId.price,
      };
    });

    const totalPrice = itemsPrice + (shippingPrice || 0) + (taxPrice || 0);

    // 🛑 STRICT ENFORCEMENT: Only "Balance" is allowed
    if (paymentMethod !== "Balance") {
      return res.status(400).json({
        message: "Only 'Balance Wallet' payment is accepted. Please choose 'Balance' or add funds to your wallet."
      });
    }

    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    if (user.balance < totalPrice) {
      return res.status(400).json({
        message: `Insufficient balance. You have $${user.balance.toFixed(2)} but need $${totalPrice.toFixed(2)}`
      });
    }

    // Deduct from balance
    user.balance -= totalPrice;
    await user.save();


    const order = await Order.create({
      userId,
      items: orderItems,
      totalPrice,
      shippingAddress,
      paymentMethod,
      shippingPrice: shippingPrice || 0,
      taxPrice: taxPrice || 0,
      status: "pending",
    });

    // Clear cart after order
    cart.items = [];
    await cart.save();

    res.status(201).json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// 📥 Get All Orders (Admin)
export const getAllOrders = async (req, res) => {
  try {
    const orders = await Order.find()
      .populate("userId", "name email")
      .populate("items.productId", "name images")
      .sort({ createdAt: -1 });

    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// 📥 Get Orders by User
export const getUserOrders = async (req, res) => {
  try {
    const orders = await Order.find({ userId: req.params.userId })
      .populate("items.productId", "name images")
      .sort({ createdAt: -1 });

    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// 📥 Get Single Order
export const getOrderById = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate("items.productId", "name images");

    if (!order)
      return res.status(404).json({ message: "Order not found" });

    res.json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ✏️ Update Order Status (Admin)
export const updateOrderStatus = async (req, res) => {
  try {
    const { status } = req.body;

    const order = await Order.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    );

    if (!order)
      return res.status(404).json({ message: "Order not found" });

    res.json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
