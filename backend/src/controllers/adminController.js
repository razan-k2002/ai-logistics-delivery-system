const pool = require("../config/db");

// ADMIN DASHBOARD
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

// GET ALL USERS
exports.getAllUsers = async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT id, name, email, role, created_at 
             FROM users 
             ORDER BY created_at DESC`
        );

        res.json({ users: result.rows });

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
};

// GET ALL DRIVERS
exports.getAllDrivers = async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT d.id, u.name, u.email, d.vehicle_type, 
                    d.license_number, d.availability_status
             FROM drivers d
             JOIN users u ON d.user_id = u.id
             ORDER BY d.availability_status DESC`
        );

        res.json({ drivers: result.rows });

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
};

// GET ALL DELIVERIES
exports.getAllDeliveries = async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT d.*, 
                    u.name AS customer_name,
                    du.name AS driver_name
             FROM deliveries d
             LEFT JOIN users u ON d.customer_id = u.id
             LEFT JOIN drivers dr ON d.driver_id = dr.id
             LEFT JOIN users du ON dr.user_id = du.id
             ORDER BY d.created_at DESC`
        );

        res.json({ deliveries: result.rows });

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
};