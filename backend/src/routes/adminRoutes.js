const express = require("express");
const router = express.Router();

const adminController = require("../controllers/adminController");
const { verifyToken } = require("../middleware/authMiddleware");

router.get("/dashboard", adminController.dashboard);
router.get("/users", verifyToken, adminController.getAllUsers);
router.get("/drivers", verifyToken, adminController.getAllDrivers);
router.get("/deliveries", verifyToken, adminController.getAllDeliveries);

module.exports = router;