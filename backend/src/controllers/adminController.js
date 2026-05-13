const pool = require("../config/db");

exports.dashboard = async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT 
                (SELECT COUNT(*) FROM deliveries) AS total_deliveries,
                (SELECT COUNT(*) FROM deliveries WHERE status='pending') AS pending,
                (SELECT COUNT(*) FROM deliveries WHERE status='in_progress') AS in_progress,
                (SELECT COUNT(*) FROM deliveries WHERE status='delivered') AS delivered,
                (SELECT COUNT(*) FROM deliveries WHERE status='cancelled') AS cancelled,
                (SELECT COUNT(*) FROM drivers WHERE availability_status=true) AS available_drivers,
                (SELECT COUNT(*) FROM users WHERE role='customer') AS total_customers
        `);

        res.json({
            message: "Admin Dashboard",
            stats: result.rows[0]
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
};