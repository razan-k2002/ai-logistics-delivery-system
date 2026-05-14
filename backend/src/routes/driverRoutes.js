const express = require("express");
const router = express.Router();

const driverController = require("../controllers/driverController");
const { verifyToken } = require("../middleware/authMiddleware");

router.get("/:id/deliveries", verifyToken, driverController.getDriverDeliveries);
router.get("/:id/performance", verifyToken, driverController.getDriverPerformance);
router.get("/by-user/:userId", verifyToken, driverController.getDriverByUserId);

module.exports = router;