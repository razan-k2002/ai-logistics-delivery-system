const pool = require("../config/db");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const SECRET = "logistics_secret_key";

// REGISTER USER
exports.register = async (req, res) => {
    try {
        const { name, email, password, role } = req.body;

        const hashedPassword = await bcrypt.hash(password, 10);

        const result = await pool.query(
            "INSERT INTO users (name, email, password, role) VALUES ($1,$2,$3,$4) RETURNING id,email,role",
            [name, email, hashedPassword, role]
        );

        const user = result.rows[0];

        // If registering as driver, add to drivers table
        if (role === 'driver') {
            await pool.query(
                "INSERT INTO drivers (user_id, availability_status) VALUES ($1, true)",
                [user.id]
            );
        }

        res.json({
            message: "User registered successfully",
            user
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Registration failed" });
    }
};

// LOGIN USER
exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        const user = await pool.query(
            "SELECT * FROM users WHERE email=$1",
            [email]
        );

        if (user.rows.length === 0) {
            return res.status(401).json({ error: "User not found" });
        }

        const validPassword = await bcrypt.compare(
            password,
            user.rows[0].password
        );

        if (!validPassword) {
            return res.status(401).json({ error: "Invalid password" });
        }

        const token = jwt.sign(
            { id: user.rows[0].id, role: user.rows[0].role },
            SECRET,
            { expiresIn: "1d" }
        );

        res.json({
        message: "Login successful",
        token,
        user: {
        id: user.rows[0].id,
        name: user.rows[0].name,
        email: user.rows[0].email,
        role: user.rows[0].role
    }
});

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Login failed" });
    }
};
// SAVE FCM TOKEN
exports.saveFcmToken = async (req, res) => {
    try {
        const { fcm_token } = req.body;
        const user_id = req.user.id;

        await pool.query(
            "UPDATE users SET fcm_token=$1 WHERE id=$2",
            [fcm_token, user_id]
        );

        res.json({ message: "FCM token saved successfully" });

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
};