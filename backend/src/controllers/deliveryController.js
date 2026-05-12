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