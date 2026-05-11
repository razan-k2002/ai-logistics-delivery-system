const express = require("express");
const router = express.Router();

const deliveryController = require("../controllers/deliveryController");
const { verifyToken } = require("../middleware/authMiddleware");

router.post("/", verifyToken, deliveryController.createDelivery);
router.get("/:id", verifyToken, deliveryController.getDelivery);

module.exports = router;