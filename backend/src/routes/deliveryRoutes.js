const express = require("express");
const router = express.Router();

const deliveryController = require("../controllers/deliveryController");
const { verifyToken } = require("../middleware/authMiddleware");

router.post("/", verifyToken, deliveryController.createDelivery);
router.get("/:id", verifyToken, deliveryController.getDelivery);
router.post("/:id/assign", verifyToken, deliveryController.assignDriver);
router.patch("/:id/status", verifyToken, deliveryController.updateStatus);
router.get("/:id/track", verifyToken, deliveryController.trackDelivery);
router.post("/:id/verify", verifyToken, deliveryController.verifyDelivery);
router.get("/customer/:customerId", verifyToken, deliveryController.getCustomerDeliveries);
module.exports = router;