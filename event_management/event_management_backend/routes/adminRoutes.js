const express = require("express");
const router = express.Router();
const Event = require("../models/Event");
const { sendApprovalEmail } = require("../utils/emailSender");
const { BASE_URL } = require("../config/config"); // Import BASE_URL from config

// Utility function to generate join link
const generateJoinLink = (eventId) => `${BASE_URL}/api/events/join/${eventId}`;

// ✅ Admin Approves Event
router.patch("/approve/:eventId", async (req, res) => {
  try {
    console.log("🔍 Approve API hit, Event ID:", req.params.eventId); // Debug Log

    const { eventId } = req.params;

    // 🔹 Find the event
    const event = await Event.findById(eventId);
    if (!event) {
      return res.status(404).json({ message: "⚠️ Event not found." });
    }

    // 🔹 Prevent re-approving or approving a rejected event
    if (event.status === "approved") {
      return res.status(400).json({ message: "⚠️ Event is already approved." });
    }
    if (event.status === "rejected") {
      return res.status(400).json({ message: "⚠️ Event has been rejected and cannot be approved." });
    }

    // ✅ Approve the event
    event.status = "approved";
    await event.save();

    // ✅ Generate attendee join link
    const joinLink = generateJoinLink(eventId);
    console.log(`ℹ️ Sending approval email to: ${event.createdBy}`);

    // ✅ Validate email before sending
    const emailRegex = /^[^\s@]+@[^\s@]+$/;
    if (!emailRegex.test(event.createdBy)) {
      return res.status(400).json({ message: "⚠️ Invalid email address for event creator." });
    }

    // ✅ Send email to the creator
    await sendApprovalEmail(event.createdBy, event.eventName, eventId);
    console.log(`📧 Email sent successfully to ${event.createdBy}`);

    res.status(200).json({
      message: "✅ Event approved successfully! Email sent to creator.",
      event,
      joinLink,
    });

  } catch (error) {
    console.error("🔥 Error approving event:", error);
    res.status(500).json({ message: "🔥 Internal Server Error", error: error.message });
  }
});

// ✅ Admin Rejects Event
router.patch("/reject/:eventId", async (req, res) => {
  try {
    console.log("🔍 Reject API hit, Event ID:", req.params.eventId); // Debug Log

    const { eventId } = req.params;

    // 🔹 Find the event
    const event = await Event.findById(eventId);
    if (!event) {
      return res.status(404).json({ message: "⚠️ Event not found." });
    }

    // 🔹 Prevent re-rejecting or rejecting an already approved event
    if (event.status === "rejected") {
      return res.status(400).json({ message: "⚠️ Event is already rejected." });
    }
    if (event.status === "approved") {
      return res.status(400).json({ message: "⚠️ Approved events cannot be rejected." });
    }

    // ✅ Reject the event
    event.status = "rejected";
    await event.save();

    res.status(200).json({ message: "❌ Event rejected successfully!", event });

  } catch (error) {
    console.error("🔥 Error rejecting event:", error);
    res.status(500).json({ message: "🔥 Internal Server Error", error: error.message });
  }
});

module.exports = router;
