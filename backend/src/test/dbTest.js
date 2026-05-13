const pool = require("../config/db");

async function testConnection() {
    try {
        const result = await pool.query("SELECT NOW()");
        console.log("DB TIME:", result.rows);
    } catch (err) {
        console.error("DB TEST ERROR:", err);
    }
}

testConnection();