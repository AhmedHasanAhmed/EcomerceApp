import express from "express";
import {
  createCategory,
  getCategories,
  getCategoryById,
  updateCategory,
  deleteCategory,
} from "../controller/categoryController.js";

const router = express.Router();

router.post("/", createCategory);      // Create
router.get("/", getCategories);        // Get all
router.get("/:id", getCategoryById);   // Get one
router.put("/:id", updateCategory);    // Update
router.delete("/:id", deleteCategory); // Delete

export default router;
