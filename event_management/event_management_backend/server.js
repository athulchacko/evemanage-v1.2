require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const cron = require("node-cron");
const nodemailer = require("nodemailer");
const connectDB = require("./config/db");

// ✅ Import Routes
const eventRoutes = require("./routes/eventRoutes");
const adminRoutes = require("./routes/adminRoutes");
const attendeeRoutes = require("./routes/attendeeRoutes");
const vendorRoutes = require("./routes/vendorRoutes");

// ✅ Import Models
const Attendee = require("./models/Attendee");
const Event = require("./models/Event");

// ✅ Connect to Database
connectDB();

const app = express();

// ✅ Middleware
app.use(cors()); // Allow cross-origin requests
app.use(express.json({ limit: "10mb" })); // Handle base64 image uploads

// ✅ Routes
app.use("/api/events", eventRoutes);
app.use("/api/admin", adminRoutes); // Admin-specific routes
app.use("/api/attendees", attendeeRoutes); // Attendee registration and management
app.use("/api/vendors", vendorRoutes); // Vendor routes

// ✅ Handle Unhandled Routes
app.use((req, res) => {
  res.status(404).json({ error: "❌ Route not found" });
});

// ✅ Global Error Handler
app.use((err, req, res, next) => {
  console.error("🔥 Global Error:", err.stack);
  res.status(500).json({ error: "❌ Internal Server Error" });
});

// ✅ Email Transporter Setup
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

// 🔹 Schedule Task: Send Reminder 1 Day Before Event
cron.schedule("0 9 * * *", async () => {
  console.log("⏳ Running daily event reminder check...");

  try {
    // Get tomorrow's date
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);

    // Get events happening tomorrow
    const events = await Event.find({
      startDate: {
        $gte: new Date(tomorrow.setHours(0, 0, 0, 0)),
        $lt: new Date(tomorrow.setHours(23, 59, 59, 999)),
      },
    });

    if (events.length === 0) {
      console.log("✅ No events scheduled for tomorrow.");
      return;
    }

    for (const event of events) {
      // Get attendees for the event
      const attendees = await Attendee.find({ eventId: event._id });

      if (attendees.length === 0) {
        console.log(`⚠️ No attendees for event ${event.eventName}`);
        continue;
      }

      for (const attendee of attendees) {
        const mailOptions = {
          from: `"Event Manager" <${process.env.SMTP_USER}>`,
          to: attendee.email,
          subject: `📅 Reminder: Your Event - ${event.eventName} is Tomorrow!`,
          html: `
            <h2>🔔 Event Reminder</h2>
            <p>Dear <b>${attendee.fullName}</b>,</p>
            <p>This is a friendly reminder that your event <b>${event.eventName}</b> is scheduled for tomorrow.</p>
            <p>📍 Location: ${event.location || "TBA"}</p>
            <p>📅 Date: ${new Date(event.startDate).toDateString()}</p>
            <p>⏰ Time: ${event.startTime || "TBA"} - ${event.endTime || "TBA"}</p>
            <p>We hope to see you there! 🎉</p>
            <hr>
            <p>For any queries, feel free to reach out.</p>
          `,
        };

        // Send email
        await transporter.sendMail(mailOptions);
      }
    }

    console.log("✅ Reminder emails sent successfully!");
  } catch (err) {
    console.error("🔥 Error in reminder cron job:", err);
  }
});

// ✅ Manual Route to Trigger Reminders
app.get("/api/reminders/test", async (req, res) => {
  try {
    console.log("🔍 Manually triggering reminder function...");
    await cron.schedule("0 9 * * *", async () => {
      console.log("⏳ Running reminder job manually...");
    });
    res.json({ message: "✅ Reminder emails sent successfully!" });
  } catch (error) {
    console.error("🔥 Error in reminder function:", error);
    res.status(500).json({
      message: "❌ Error executing reminder function",
      error: error.message,
    });
  }
});

// ✅ Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
