import express from 'express';
import { loginUser, registerUser, getAllUsers, deleteUser, updateUserRole, updateUserProfile, addPayment, getWishlist, toggleWishlist } from '../controller/UserController.js';


const userRouter = express.Router();
userRouter.post('/register', registerUser);
userRouter.post('/login', loginUser);
userRouter.get('/getUsers', getAllUsers);
userRouter.delete('/:id', deleteUser);
userRouter.put('/:id/profile', updateUserProfile);
userRouter.put('/:id/role', updateUserRole);
userRouter.post('/:id/payment', addPayment);
userRouter.get('/:id/wishlist', getWishlist);
userRouter.post('/:id/wishlist/:productId', toggleWishlist);

export default userRouter;
