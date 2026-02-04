import express from 'express';
import { connect } from 'mongoose';
import conectBD from './config/db.js';
import { registerUser } from './controller/UserController.js';
import userRouter from './routes/UserRoute.js';

import cookieParser from 'cookie-parser';
import TokenRoute from './routes/TokenRoute.js';
import productRoutes from './routes/productRoutes.js'
import categoryRoutes from './routes/categoryRoutes.js'
import cartRoutes from './routes/cartRoutes.js'
import orderRoutes from './routes/orderRoutes.js'
import statsRoute from './routes/statsRoute.js'
import cors from "cors";
import { port } from './config/config.js';
const app = express();
const PORT = port || 8000;

app.use(express.json());
app.use(cookieParser());
app.use(cors({
  origin: "*", // Allow all for easier free deployment
  credentials: true,
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization", "Cookie"],
  exposedHeaders: ["Set-Cookie"]
}));
app.use('/api/user', userRouter);
app.use("/api/products", productRoutes);
app.use("/api/categories", categoryRoutes);
app.use("/api/cart", cartRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/stats", statsRoute);


// forget password
app.use('/api/forgetpassword', TokenRoute);


conectBD();
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);

})
