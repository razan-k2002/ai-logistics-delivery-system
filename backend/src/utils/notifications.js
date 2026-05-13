const admin = require("../config/firebase");

const sendNotification = async (token, title, body) => {
    try {
        const message = {
            notification: { title, body },
            token
        };
        const response = await admin.messaging().send(message);
        console.log("Notification sent:", response);
        return response;
    } catch (error) {
        console.error("Notification error:", error.message);
    }
};

module.exports = { sendNotification };