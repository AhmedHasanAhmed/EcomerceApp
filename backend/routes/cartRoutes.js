import express from "express";
import {
  addToCart,
  getCartByUser,
  updateCartItem,
  removeCartItem,
  clearCart,
} from "../controller/cartController.js";

const router = express.Router();

router.post("/add", addToCart); // add item
router.get("/:userId", getCartByUser); // get cart
router.put("/:userId/:productId", updateCartItem); // update qty
router.delete("/:userId/:productId", removeCartItem); // remove item
router.delete("/:userId", clearCart); // clear cart

export default router;
