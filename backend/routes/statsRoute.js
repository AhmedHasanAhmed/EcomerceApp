import express from "express";
import { getDashboardStats } from "../controller/statsController.js";

const router = express.Router();

router.get("/", getDashboardStats);

export default router;
