import Order from "../model/Order.js";
import Product from "../model/Product.js";
import User from "../model/User.js";

export const getDashboardStats = async (req, res) => {
    try {
        const totalOrders = await Order.countDocuments();
        const totalProducts = await Product.countDocuments();
        const totalUsers = await User.countDocuments();

        const orders = await Order.find();
        const totalSales = orders
            .reduce((acc, curr) => acc + curr.totalPrice, 0);

        const recentOrders = await Order.find()
            .populate("userId", "name")
            .sort({ createdAt: -1 })
            .limit(5);

        res.status(200).json({
            totalSales,
            totalOrders,
            totalProducts,
            totalUsers,
            recentOrders
        });
    } catch (error) {
        res.status(500).json({ message: "Error fetching stats: " + error.message });
    }
};
