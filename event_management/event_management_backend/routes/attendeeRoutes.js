const express = require("express");
const nodemailer = require("nodemailer");
const Attendee = require("../models/Attendee");
const Event = require("../models/Event");

const router = express.Router();

// ✅ Email Transporter Setup
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

// 📌 Register an attendee
router.post("/register", async (req, res) => {
  try {
    const { eventId, name, branchCode, email, phone, paymentProof } = req.body;

    // 🔹 Validate required fields
    if (!eventId || !name || !email || !branchCode || !phone) {
      return res.status(400).json({ message: "⚠️ Missing required fields." });
    }

    // 🔹 Check if event exists
    const event = await Event.findById(eventId);
    if (!event) {
      return res.status(404).json({ message: "⚠️ Event not found." });
    }

    // 🔹 Validate payment proof for paid events
    if (event.isPaid && (!paymentProof || paymentProof.trim() === "")) {
      return res.status(400).json({ message: "⚠️ Payment proof is required for paid events." });
    }

    // 🔹 Check if attendee is already registered
    const existingAttendee = await Attendee.findOne({ eventId, email });
    if (existingAttendee) {
      return res.status(400).json({ message: "⚠️ You have already registered for this event." });
    }

    // 🔹 Create a new attendee
    const newAttendee = new Attendee({
      eventId,
      name,
      branchCode,
      email,
      phone,
      paymentProof: event.isPaid ? paymentProof : null, // Only store if event is paid
    });

    await newAttendee.save();

    // ✅ Send confirmation email
    const mailOptions = {
      from: `"Event Manager" <${process.env.SMTP_USER}>`,
      to: email,
      subject: `✅ Registration Confirmation - ${event.eventName}`,
      html: `
        <h2>🎉 Registration Successful!</h2>
        <p>Dear <b>${name}</b>,</p>
        <p>Thank you for registering for <b>${event.eventName}</b>.</p>
        <p>📅 Date: ${new Date(event.startDate).toDateString()}</p>
        <p>📍 Location: ${event.location || "TBA"}</p>
        <p>⏰ Time: ${event.startTime || "TBA"} - ${event.endTime || "TBA"}</p>
        <p>We look forward to seeing you there! 🚀</p>
        <hr>
        <p>If you have any questions, feel free to contact us.</p>
      `,
    };

    await transporter.sendMail(mailOptions);

    res.status(201).json({ message: "✅ Registration successful. Confirmation email sent!" });

  } catch (error) {
    console.error("🔥 Error registering attendee:", error);
    res.status(500).json({ message: "⚠️ Internal Server Error", error: error.message });
  }
});

// 📌 Get attendees for an event
router.get("/:eventId", async (req, res) => {
  try {
    const { eventId } = req.params;

    if (!eventId) {
      return res.status(400).json({ message: "⚠️ Event ID is required." });
    }

    const attendees = await Attendee.find({ eventId }).select("-__v");

    if (attendees.length === 0) {
      return res.status(404).json({ message: "⚠️ No attendees found for this event." });
    }

    res.status(200).json(attendees);
  } catch (err) {
    console.error("🔥 Error fetching attendees:", err);
    res.status(500).json({ message: "🔥 Internal Server Error", error: err.message });
  }
});

// 📌 Remove an attendee
router.delete("/remove/:attendeeId", async (req, res) => {
  try {
    const { attendeeId } = req.params;

    if (!attendeeId) {
      return res.status(400).json({ message: "⚠️ Attendee ID is required." });
    }

    const deletedAttendee = await Attendee.findByIdAndDelete(attendeeId);
    if (!deletedAttendee) {
      return res.status(404).json({ message: "⚠️ Attendee not found." });
    }

    res.status(200).json({ message: "✅ Attendee removed successfully." });
  } catch (err) {
    console.error("🔥 Error removing attendee:", err);
    res.status(500).json({ message: "🔥 Internal Server Error", error: err.message });
  }
});

// 📌 Send Reminder Emails to Attendees
router.post("/send-reminder/:eventId", async (req, res) => {
  try {
    const { eventId } = req.params;

    const event = await Event.findById(eventId);
    if (!event) {
      return res.status(404).json({ message: "⚠️ Event not found." });
    }

    const attendees = await Attendee.find({ eventId });

    if (attendees.length === 0) {
      return res.status(404).json({ message: "⚠️ No attendees found for this event." });
    }

    // 🔹 Send emails
    const emailPromises = attendees.map(async (attendee) => {
      try {
        const mailOptions = {
          from: `"Event Manager" <${process.env.SMTP_USER}>`,
          to: attendee.email,
          subject: `📅 Reminder: Upcoming Event - ${event.eventName}`,
          html: `
            <h2>🔔 Event Reminder</h2>
            <p>Dear <b>${attendee.name}</b>,</p>
            <p>We are excited to remind you about your upcoming event <b>${event.eventName}</b>.</p>
            <p>📍 Location: ${event.location || "TBA"}</p>
            <p>📅 Date: ${new Date(event.startDate).toDateString()}</p>
            <p>⏰ Time: ${event.startTime || "TBA"} - ${event.endTime || "TBA"}</p>
            <p>We look forward to seeing you there! 🚀</p>
          `,
        };

        return await transporter.sendMail(mailOptions);
      } catch (error) {
        console.error(`⚠️ Failed to send email to ${attendee.email}:`, error);
      }
    });

    await Promise.all(emailPromises);
    res.status(200).json({ message: "✅ Reminder emails sent successfully!" });
  } catch (err) {
    console.error("🔥 Error sending reminder:", err);
    res.status(500).json({ message: "🔥 Internal Server Error", error: err.message });
  }
});

module.exports = router;
