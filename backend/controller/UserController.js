import { jwt_secret } from "../config/config.js";
import User from "../model/User.js";
import jwt from "jsonwebtoken";
import bcrypt from "bcrypt";

/**  REGISTER  **/
export const registerUser = async (req, res) => {
  try {
    const { email, name, password, role } = req.body;

    if (!email || !name || !password) {
      return res.status(400).json({ message: "Geli dhammaan meelaha banaan" });
    }

    // check if user exists
    const existingUser = await User.findOne({ email: email.toLowerCase() });

    if (existingUser) {
      return res.status(400).json({ message: "Email-kaan hore ayaa loo diwaangeliyay" });
    }

    const userInfo = new User({
      email: email.toLowerCase(),
      name: name,
      password,
      ...(role && { role }),
    });

    await userInfo.save();
    res.status(201).json({ message: "User registered successfully" });
  } catch (error) {
    console.error("Error in registering user:", error);
    res.status(500).json({ message: "Error in registering user: " + error.message });
  }
};

/**  LOGIN  **/
export const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: "Geli email-ka iyo password-ka" });
    }

    const user = await User.findOne({ email: email.toLowerCase() }).select("+password");

    if (!user) {
      return res.status(400).json({ message: "User-kaan ma jiro" });
    }

    const isPasswordCorrect = await user.comparePassword(password);
    if (!isPasswordCorrect) {
      return res.status(400).json({ message: "Password-ka waa qalad" });
    }

    const expirein = 7 * 24 * 60 * 60; // 7 days in seconds
    const token = jwt.sign({ _id: user._id, role: user.role }, jwt_secret, { expiresIn: expirein });

    res.cookie("token", token, {
      httpOnly: true,
      secure: false,
      maxAge: expirein * 1000
    });

    const userObj = user.toJSON();
    delete userObj.password;

    res.status(200).send({ ...userObj, token, expirein });

  } catch (error) {
    console.log("Error in logging in user:", error);
    res.status(500).json({ message: "Error in logging in user" });
  }
};

// get all users
export const getAllUsers = async (req, res) => {
  try {
    const users = await User.find().select("-password");
    res.status(200).json(users);
  } catch (error) {
    res.status(500).json({ success: false, message: "Error fetching users", error: error.message });
  }
};

// delete user
export const deleteUser = async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);
    if (!user) return res.status(404).json({ message: "User not found" });
    res.status(200).json({ message: "User deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: "Error deleting user" });
  }
};

// update user role
export const updateUserRole = async (req, res) => {
  try {
    const { role } = req.body;
    const user = await User.findByIdAndUpdate(req.params.id, { role }, { new: true });
    if (!user) return res.status(404).json({ message: "User not found" });
    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ message: "Error updating role" });
  }
};

// update user profile (name, email, image)
export const updateUserProfile = async (req, res) => {
  try {
    const { name, email, image } = req.body;
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { name, email, image },
      { new: true }
    ).select("-password");

    if (!user) return res.status(404).json({ message: "User not found" });
    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ message: "Error updating profile" });
  }
};

// add payment (demo - just updates balance)
export const addPayment = async (req, res) => {
  try {
    const { amount } = req.body;
    const user = await User.findById(req.params.id);

    if (!user) return res.status(404).json({ message: "User not found" });

    user.balance = (user.balance || 0) + amount;
    await user.save();

    res.status(200).json({ balance: user.balance, message: "Payment added successfully" });
  } catch (error) {
    res.status(500).json({ message: "Error adding payment" });
  }
};
// get wishlist
export const getWishlist = async (req, res) => {
  try {
    const user = await User.findById(req.params.id).populate("wishlist");
    if (!user) return res.status(404).json({ message: "User not found" });
    res.status(200).json(user.wishlist);
  } catch (error) {
    res.status(500).json({ message: "Error fetching wishlist" });
  }
};

// toggle wishlist
export const toggleWishlist = async (req, res) => {
  try {
    const { productId } = req.params;
    const user = await User.findById(req.params.id); // Assuming ID comes from param or middleware

    if (!user) return res.status(404).json({ message: "User not found" });

    const isFav = user.wishlist.some(id => id.toString() === productId);
    if (isFav) {
      user.wishlist = user.wishlist.filter(id => id.toString() !== productId);
    } else {
      user.wishlist.push(productId);
    }

    await user.save();
    res.status(200).json({
      message: isFav ? "Removed from wishlist" : "Added to wishlist",
      wishlist: user.wishlist
    });
  } catch (error) {
    res.status(500).json({ message: "Error toggling wishlist" });
  }
};
