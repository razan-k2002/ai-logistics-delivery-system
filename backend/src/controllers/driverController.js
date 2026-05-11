const pool = require("../config/db");

// GET DRIVER DELIVERIES
exports.getDriverDeliveries = async (req, res) => {

    try {

        const { id } = req.params;

        const deliveries = await pool.query(
            "SELECT * FROM deliveries WHERE driver_id=$1",
            [id]
        );

        res.json(deliveries.rows);

    } catch (error) {

        res.status(500).json({ error: "Driver deliveries error" });

    }

};