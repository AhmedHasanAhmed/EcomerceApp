import express from "express";
import {
  createOrder,
  getUserOrders,
  getAllOrders,
  getOrderById,
  updateOrderStatus,
} from "../controller/orderController.js";

const router = express.Router();

router.post("/", createOrder);
router.get("/", getAllOrders);                 // all orders (Admin)
router.get("/user/:userId", getUserOrders);
router.get("/:id", getOrderById);
router.put("/:id/status", updateOrderStatus);

export default router;
