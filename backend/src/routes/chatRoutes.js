const express = require("express");
const router = express.Router();
const axios = require("axios");
const pool = require("../config/db");
const { verifyToken } = require("../middleware/authMiddleware");

router.post("/", verifyToken, async (req, res) => {
    try {
        const { message } = req.body;
        const userId = req.user.id;
        const userRole = req.user.role;

        // Get intent from Flask chatbot
        const chatResponse = await axios.post("http://127.0.0.1:5000/chat", {
            message,
            role: userRole
        });

        const { intent, response, action, confidence } = chatResponse.data;

        // Execute action based on intent
        let actionData = null;

        if (action === "FETCH_DELIVERY_STATUS" || action === "FETCH_ETA") {
            // Get latest delivery for this customer
            const result = await pool.query(
                `SELECT d.*, du.name AS driver_name 
                 FROM deliveries d
                 LEFT JOIN drivers dr ON d.driver_id = dr.id
                 LEFT JOIN users du ON dr.user_id = du.id
                 WHERE d.customer_id = $1 
                 ORDER BY d.created_at DESC LIMIT 1`,
                [userId]
            );
            if (result.rows.length > 0) {
                const delivery = result.rows[0];
                actionData = {
                    delivery_id: delivery.id,
                    status: delivery.status,
                    estimated_time: delivery.estimated_time,
                    pickup_location: delivery.pickup_location,
                    delivery_location: delivery.delivery_location,
                    driver_name: delivery.driver_name,
                    tracking_id: delivery.tracking_id
                };
            }
        }

        else if (action === "FETCH_DRIVER_DELIVERIES") {
            const driverResult = await pool.query(
                "SELECT id FROM drivers WHERE user_id=$1", [userId]
            );
            if (driverResult.rows.length > 0) {
                const driverId = driverResult.rows[0].id;
                const result = await pool.query(
                    "SELECT * FROM deliveries WHERE driver_id=$1 AND status='in_progress'",
                    [driverId]
                );
                actionData = { deliveries: result.rows };
            }
        }

        else if (action === "FETCH_PENDING_COUNT") {
            const result = await pool.query(
                "SELECT COUNT(*) AS pending FROM deliveries WHERE status='pending'"
            );
            actionData = { pending_count: result.rows[0].pending };
        }

        else if (action === "FETCH_AVAILABLE_DRIVERS") {
            const result = await pool.query(
                `SELECT d.id, u.name FROM drivers d 
                 JOIN users u ON d.user_id = u.id 
                 WHERE d.availability_status=true`
            );
            actionData = { 
                available_count: result.rows.length,
                drivers: result.rows 
            };
        }

        else if (action === "FETCH_ANALYTICS") {
            const result = await pool.query(`
                SELECT 
                    (SELECT COUNT(*) FROM deliveries) AS total,
                    (SELECT COUNT(*) FROM deliveries WHERE status='pending') AS pending,
                    (SELECT COUNT(*) FROM deliveries WHERE status='delivered') AS delivered,
                    (SELECT COUNT(*) FROM drivers WHERE availability_status=true) AS available_drivers
            `);
            actionData = result.rows[0];
        }

        // Build smart response with data
        let finalResponse = response;

        if (actionData) {
            if (action === "FETCH_DELIVERY_STATUS" && actionData.delivery_id) {
                finalResponse = `Your latest delivery #DEL${String(actionData.delivery_id).padStart(3, '0')} is currently ${actionData.status.replace('_', ' ')}.`;
                if (actionData.driver_name) {
                    finalResponse += ` Driver: ${actionData.driver_name}.`;
                }
            } else if (action === "FETCH_ETA" && actionData.estimated_time) {
                finalResponse = `Estimated arrival time for your latest delivery is ${actionData.estimated_time} minutes.`;
            } else if (action === "FETCH_PENDING_COUNT") {
                finalResponse = `There are currently ${actionData.pending_count} pending deliveries waiting for driver assignment.`;
            } else if (action === "FETCH_AVAILABLE_DRIVERS") {
                finalResponse = `There are ${actionData.available_count} drivers currently available.`;
            } else if (action === "FETCH_ANALYTICS") {
                finalResponse = `System overview: ${actionData.total} total deliveries, ${actionData.pending} pending, ${actionData.delivered} delivered, ${actionData.available_drivers} drivers available.`;
            } else if (action === "FETCH_DRIVER_DELIVERIES") {
                const count = actionData.deliveries?.length || 0;
                finalResponse = count > 0 
                    ? `You have ${count} active delivery/deliveries assigned to you.`
                    : "You have no active deliveries assigned right now.";
            }
        }

        res.json({
            message: finalResponse,
            action,
            action_data: actionData,
            intent,
            confidence
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;