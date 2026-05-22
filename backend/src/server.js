const express = require("express");
const app = express();

const authRoutes = require("./routes/authRoutes");
const deliveryRoutes = require("./routes/deliveryRoutes");
const driverRoutes = require("./routes/driverRoutes");
const adminRoutes = require("./routes/adminRoutes");
const notificationRoutes = require("./routes/notificationRoutes");

app.use("/api/notifications", notificationRoutes);
app.use(express.json());
app.use("/api/auth", authRoutes);
app.use("/api/deliveries", deliveryRoutes);
app.use("/api/drivers", driverRoutes);
app.use("/api/admin", adminRoutes);

app.get("/", (req, res) => {
    res.send("🚀 AI Logistics Backend Running");
});

app.listen(3000, () => {
    console.log("Server running on port 3000");
});