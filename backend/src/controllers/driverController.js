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
// GET DRIVER PERFORMANCE
exports.getDriverPerformance = async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(
            `SELECT
                COUNT(*) AS total_deliveries,
                COUNT(CASE WHEN status = 'delivered' THEN 1 END) AS completed_deliveries,
                COUNT(CASE WHEN status = 'cancelled' THEN 1 END) AS cancelled_deliveries,
                ROUND(AVG(actual_delivery_time)) AS avg_delivery_time_minutes,
                COUNT(CASE WHEN actual_delivery_time <= estimated_time THEN 1 END) AS on_time_deliveries,
                ROUND(
                    COUNT(CASE WHEN actual_delivery_time <= estimated_time THEN 1 END) * 100.0 /
                    NULLIF(COUNT(CASE WHEN status = 'delivered' THEN 1 END), 0)
                ) AS on_time_rate_percent
             FROM deliveries
             WHERE driver_id = $1`,
            [id]
        );

        const driver = await pool.query(
            `SELECT d.id, u.name, d.vehicle_type, d.license_number, d.availability_status
             FROM drivers d
             JOIN users u ON d.user_id = u.id
             WHERE d.id = $1`,
            [id]
        );

        if (driver.rows.length === 0) {
            return res.status(404).json({ error: "Driver not found" });
        }

        res.json({
            driver: driver.rows[0],
            performance: result.rows[0]
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
};
// GET DRIVER BY USER ID
exports.getDriverByUserId = async (req, res) => {
    try {
        const { userId } = req.params;
        const result = await pool.query(
            `SELECT d.id, d.vehicle_type, d.license_number, d.availability_status
             FROM drivers d
             WHERE d.user_id = $1`,
            [userId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Driver not found" });
        }

        res.json({ driver: result.rows[0] });

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
};