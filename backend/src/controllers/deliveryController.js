const pool = require("../config/db");
const axios = require("axios");
// CREATE DELIVERY
exports.createDelivery = async (req, res) => {
    try {
        const { pickup_location, delivery_location, customer_id, pickup_coords, delivery_coords } = req.body;

        const result = await pool.query(
            `INSERT INTO deliveries (pickup_location, delivery_location, customer_id, status)
             VALUES ($1,$2,$3,'pending')
             RETURNING *`,
            [pickup_location, delivery_location, customer_id]
        );

        const delivery = result.rows[0];

        // Call AI service to optimize route
        let optimizedRoute = null;
if (pickup_coords && delivery_coords) {
    try {
        const aiResponse = await axios.post("http://127.0.0.1:5000/optimize", {
            locations: [pickup_coords, delivery_coords]
        });
        optimizedRoute = aiResponse.data;

        // Save estimated time to database
        const estimatedMinutes = Math.round(optimizedRoute.total_duration_minutes);
        await pool.query(
            "UPDATE deliveries SET estimated_time=$1 WHERE id=$2",
            [estimatedMinutes, delivery.id]
        );
        delivery.estimated_time = estimatedMinutes;

    } catch (aiError) {
        console.error("AI service error:", aiError.message);
        console.error("AI service full error:", aiError.response?.data);
    }
}

res.json({
    message: "Delivery created successfully",
    delivery,
    optimized_route: optimizedRoute
});

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
};

// GET DELIVERY BY ID
exports.getDelivery = async (req, res) => {

    try {

        const { id } = req.params;

        const result = await pool.query(
            "SELECT * FROM deliveries WHERE id=$1",
            [id]
        );

        res.json(result.rows[0]);

    } catch (error) {

        res.status(500).json({ error: "Error retrieving delivery" });

    }

};
// ASSIGN DRIVER TO DELIVERY
exports.assignDriver = async (req, res) => {
    try {
        const { id } = req.params;
        const { driver_id } = req.body;

        // Check if delivery exists and is still pending
        const delivery = await pool.query(
            "SELECT * FROM deliveries WHERE id=$1",
            [id]
        );

        if (delivery.rows.length === 0) {
            return res.status(404).json({ error: "Delivery not found" });
        }

        if (delivery.rows[0].status !== "pending") {
            return res.status(400).json({ error: "Delivery is no longer pending" });
        }

        // Check if driver exists and is available
        const driver = await pool.query(
            "SELECT * FROM drivers WHERE id=$1 AND availability_status=true",
            [driver_id]
        );

        if (driver.rows.length === 0) {
            return res.status(404).json({ error: "Driver not found or not available" });
        }

        // Assign driver and update status
        const result = await pool.query(
            `UPDATE deliveries 
             SET driver_id=$1, status='in_progress' 
             WHERE id=$2 
             RETURNING *`,
            [driver_id, id]
        );

        // Set driver availability to false
        await pool.query(
            "UPDATE drivers SET availability_status=false WHERE id=$1",
            [driver_id]
        );

        res.json({
            message: "Driver assigned successfully",
            delivery: result.rows[0]
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
};

// UPDATE DELIVERY STATUS
exports.updateStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;

        // Validate status value
        const validStatuses = ["pending", "in_progress", "delivered", "cancelled"];
        if (!validStatuses.includes(status)) {
            return res.status(400).json({ 
                error: "Invalid status. Must be: pending, in_progress, delivered, or cancelled" 
            });
        }

        // Check if delivery exists
        const delivery = await pool.query(
            "SELECT * FROM deliveries WHERE id=$1",
            [id]
        );

        if (delivery.rows.length === 0) {
            return res.status(404).json({ error: "Delivery not found" });
        }

        // Calculate actual delivery time in minutes
let actualTime = null;
if (status === "delivered") {
    const createdAt = new Date(delivery.rows[0].created_at);
    const now = new Date();
    actualTime = Math.round((now - createdAt) / 60000);
}

// Update status
const result = await pool.query(
    `UPDATE deliveries 
     SET status=$1, actual_delivery_time=$2
     WHERE id=$3 
     RETURNING *`,
    [status, actualTime, id]
);

        // If delivered or cancelled, free up the driver
        if (status === "delivered" || status === "cancelled") {
            const driverId = delivery.rows[0].driver_id;
            if (driverId) {
                await pool.query(
                    "UPDATE drivers SET availability_status=true WHERE id=$1",
                    [driverId]
                );
            }
        }

        res.json({
            message: "Delivery status updated successfully",
            delivery: result.rows[0]
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
};
// TRACK DELIVERY
exports.trackDelivery = async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(
            `SELECT 
                d.id,
                d.status,
                d.pickup_location,
                d.delivery_location,
                d.estimated_time,
                d.created_at,
                u.name AS customer_name,
                dr.id AS driver_id,
                du.name AS driver_name,
                dr.vehicle_type,
                dr.license_number
             FROM deliveries d
             LEFT JOIN users u ON d.customer_id = u.id
             LEFT JOIN drivers dr ON d.driver_id = dr.id
             LEFT JOIN users du ON dr.user_id = du.id
             WHERE d.id = $1`,
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Delivery not found" });
        }

        const delivery = result.rows[0];

        res.json({
            delivery_id: delivery.id,
            status: delivery.status,
            pickup_location: delivery.pickup_location,
            delivery_location: delivery.delivery_location,
            estimated_time: delivery.estimated_time,
            created_at: delivery.created_at,
            customer: {
                name: delivery.customer_name
            },
            driver: delivery.driver_id ? {
                id: delivery.driver_id,
                name: delivery.driver_name,
                vehicle_type: delivery.vehicle_type,
                license_number: delivery.license_number
            } : null
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
};