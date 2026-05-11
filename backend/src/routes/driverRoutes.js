const express = require("express");
const router = express.Router();

const driverController = require("../controllers/driverController");
const { verifyToken } = require("../middleware/authMiddleware");

router.get("/:id/deliveries", verifyToken, driverController.getDriverDeliveries);

module.exports = router;