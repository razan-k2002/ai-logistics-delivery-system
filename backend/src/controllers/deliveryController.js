const pool = require("../config/db");

// CREATE DELIVERY
exports.createDelivery = async (req, res) => {
    try {

        const { pickup_location, delivery_location, customer_id } = req.body;

const result = await pool.query(
    `INSERT INTO deliveries (pickup_location, delivery_location, customer_id, status)
     VALUES ($1,$2,$3,'pending')
     RETURNING *`,
    [pickup_location, delivery_location, customer_id]
);
        res.json({
            message: "Delivery created successfully",
            delivery: result.rows[0]
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