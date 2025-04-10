const express = require("express");
const Event = require("../models/Event");
const nodemailer = require("nodemailer");
const moment = require("moment-timezone"); // Import moment-timezone
require("dotenv").config();

const router = express.Router();

const frontendBaseUrl = process.env.FRONTEND_BASE_URL || "http://localhost:61511/#"; // Use environment variable or fallback to localhost

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: process.env.SMTP_PORT,
  secure: process.env.SMTP_PORT === "465", // Use true for port 465 (SSL/TTLS), false otherwise
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});


// ✅ Convert 12-hour time format to 24-hour format
const convertTo24HourFormat = (timeStr) => {
  const match = timeStr.match(/(\d{1,2}):(\d{2})\s?(AM|PM)/i);
  if (!match) return timeStr; // Already in HH:mm format

  let [_, hours, minutes, period] = match;
  hours = parseInt(hours, 10);

  if (period.toUpperCase() === "PM" && hours !== 12) {
    hours += 12;
  } else if (period.toUpperCase() === "AM" && hours === 12) {
    hours = 0; // Convert 12 AM to 00
  }

  return `${String(hours).padStart(2, "0")}:${minutes}`;
};

// ✅ Validate Date Format (YYYY-MM-DD)
const isValidDateFormat = (dateStr) => {
  // Extract only 'YYYY-MM-DD' if date is in ISO format
  if (dateStr.includes("T")) {
    dateStr = dateStr.split("T")[0];
  }
  return /^\d{4}-\d{2}-\d{2}$/.test(dateStr);
};

// ✅ Convert Date + Time to UTC
const parseDateTime = (date, time) => {
  return new Date(`${date}T${time}:00Z`);
};

// 🚀 Create Event API Route
router.post("/create", async (req, res) => {
  console.log("🛠 Debug - Incoming Request Body:", req.body);
  try {
    // 🛠 Extract fields from request body
    const {
      eventName,
      location,
      startDate,
      endDate,
      startTime,
      endTime,
      createdBy,
      isPaid = false,
      eventThumbnail = null,
      idCardImage = null,
    } = req.body;

    // Extract 'YYYY-MM-DD' if in ISO format
    const formattedStartDate = startDate.includes("T") ? startDate.split("T")[0] : startDate;
    const formattedEndDate = endDate.includes("T") ? endDate.split("T")[0] : endDate;

    // 🔹 Validate date format
    if (!isValidDateFormat(formattedStartDate) || !isValidDateFormat(formattedEndDate)) {
      return res.status(400).json({ message: "⚠️ Invalid date format. Use YYYY-MM-DD." });
    }

    // 🔹 Validate required fields
    if (!eventName || !location || !startDate || !endDate || !startTime || !endTime || !createdBy) {
      return res.status(400).json({ message: "⚠️ Missing required fields: eventName, location, startDate, endDate, startTime, endTime, or createdBy." });
    }

    

   // 🔹 Convert time to 24-hour format
   const formattedStartTime = convertTo24HourFormat(startTime);
   const formattedEndTime = convertTo24HourFormat(endTime);

   if (!/^\d{2}:\d{2}$/.test(formattedStartTime) || !/^\d{2}:\d{2}$/.test(formattedEndTime)) {
     return res.status(400).json({ message: "⚠️ Invalid time format. Use HH:mm (24-hour format)." });
   }

   // 🔹 Convert to UTC DateTime
   const parsedStartDate = new Date(`${formattedStartDate}T${formattedStartTime}:00Z`);
   const parsedEndDate = new Date(`${formattedEndDate}T${formattedEndTime}:00Z`);

   console.log("Parsed Start Date:", parsedStartDate);
   console.log("Parsed End Date:", parsedEndDate);

   if (isNaN(parsedStartDate) || isNaN(parsedEndDate)) {
     return res.status(400).json({ message: "⚠️ Invalid date or time format. Use YYYY-MM-DD for dates and HH:mm for times." });
   }

   if (parsedEndDate <= parsedStartDate) {
     return res.status(400).json({ message: "⚠️ End date/time must be after start date/time." });
   }

    // 🔹 Check for conflicts with existing events at the same location
    const existingEvent = await Event.findOne({
      location,
      status: { $ne: "rejected" },
      $or: [
        { startDate: { $lte: parsedStartDate }, endDate: { $gte: parsedStartDate } },
        { startDate: { $lte: parsedEndDate }, endDate: { $gte: parsedEndDate } },
        { startDate: { $gte: parsedStartDate }, endDate: { $lte: parsedEndDate } },
      ],
    });

    if (existingEvent) {
      return res.status(400).json({
        message: `⚠️ Event conflict! Another event "${existingEvent.eventName}" is already scheduled at ${location} from ${existingEvent.startDate} to ${existingEvent.endDate}.`,
      });
    }
    console.log("✅ No conflicts found. Proceeding to create event...");
    // ✅ Create new event
    const newEvent = new Event({
      eventName,
      location,
      startDate: parsedStartDate,
      endDate: parsedEndDate,
      startTime: formattedStartTime,
      endTime: formattedEndTime,
      createdBy,
      isPaid,
      eventThumbnail,
      idCardImage,
      status: "pending",
    });

    await newEvent.save();

    // ✅ Send success response
    res.status(201).json({ message: "✅ Event created successfully and submitted for approval!" });

  } catch (error) {
    console.error("🔥 Error creating event:", error);
    res.status(500).json({ message: "🔥 Internal Server Error", error: error.message });
  }
});

// ✅ Admin Approves Event
router.put("/approve/:eventId", async (req, res) => { 
  try {
    const { eventId } = req.params;

    const event = await Event.findById(eventId);
    if (!event) {
      return res.status(404).json({ error: "Event not found" });
    }

    if (event.isApproved) {
      return res.status(400).json({ error: "Event is already approved" });
    }

    const frontendBaseUrl = process.env.FRONTEND_BASE_URL || "http://localhost:5000";
    const joinLink = `${frontendBaseUrl}/join/${eventId}`;
        event.isApproved = true;
    event.joinLink = joinLink;

    await event.save();

    await sendApprovalEmail(event.createdBy, event.eventName, joinLink);

    res.json({ message: "✅ Event approved successfully!", event });

  } catch (error) {
    console.error("🔥 Error approving event:", error);
    res.status(500).json({ error: "Error approving event" });
  }
});


// ✅ Get details of an approved event by ID
router.get("/approved/:eventId", async (req, res) => {
  try {
    const { eventId } = req.params;
    const event = await Event.findOne({ _id: eventId, status: "approved" });

    if (!event) {
      return res.status(404).json({ message: "⚠️ Approved event not found." });
    }

    res.status(200).json(event);
  } catch (error) {
    console.error("🔥 Error fetching approved event details:", error);
    res.status(500).json({ message: "🔥 Internal Server Error", error: error.message });
  }
});



// ✅ Attendees Register for an Approved Event
router.post("/join/:eventId", async (req, res) => {
  try {
    const { name, branchCode, email, phone, paymentProof } = req.body;

    if (!name || !email) {
      return res.status(400).json({ message: "⚠️ Missing required fields: name or email." });
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({ message: "⚠️ Invalid email format." });
    }

    const event = await Event.findById(req.params.eventId);

    if (!event) {
      return res.status(404).json({ message: "⚠️ Event not found." });
    }

    if (event.status !== "approved") {
      return res.status(400).json({ message: "⚠️ Event is not approved yet." });
    }

    event.attendees.push({
      name,
      branchCode: branchCode || null,
      email,
      phone: phone || null,
      paymentProof: paymentProof || null,
    });

    await event.save();

    res.json({ message: "✅ Successfully registered for the event!" });
  } catch (err) {
    console.error("🔥 Error joining event:", err);
    res.status(500).json({ message: "🔥 Error joining event", error: err.message });
  }
});

// ✅ Get all pending approval events
router.get("/pending", async (req, res) => {
  try {
    const pendingEvents = await Event.find({ status: "pending" });
    res.status(200).json(pendingEvents);
  } catch (error) {
    console.error("🔥 Error fetching pending events:", error);
    res.status(500).json({ message: "Error fetching pending events", error });
  }
});

router.get("/approved", async (req, res) => {
  try {
    const approvedEvents = await Event.find({ status: "approved" });
    res.json(approvedEvents);
  } catch (error) {
    res.status(500).json({ message: "Error fetching approved events", error });
  }
});



// ✅ Update Event Approval Status
router.put("/events/approval:id", async (req, res) => {
  console.log("🔍 Update Event Approval API hit, Event ID:", req.params.id);
  const { status } = req.body; // 'approved' or 'rejected'

  if (!["approved", "rejected"].includes(status)) {
    return res.status(400).json({ message: "Invalid approval status" });
  }

  try {
    const updatedEvent = await Event.findByIdAndUpdate(
      req.params.id,
      { status: status },
      { new: true }
    );

    if (!updatedEvent) {
      return res.status(404).json({ message: "Event not found" });
    }

    res.status(200).json({ message: `Event ${status} successfully`, updatedEvent });
  } catch (error) {
    console.error("🔥 Error updating event approval:", error);
    res.status(500).json({ message: "Error updating event approval", error });
  }
});



router.get("/user-events/:email", async (req, res) => {
  try {
    const { email } = req.params;

    if (!email) {
      return res.status(400).json({ message: "❌ Email parameter is required" });
    }

    const events = await Event.find({ createdBy: email });

    if (events.length === 0) {
      return res.status(404).json({ message: "⚠️ No events found for this user" });
    }

    res.status(200).json(events);
  } catch (error) {
    console.error("🔥 Error fetching user events:", error);
    res.status(500).json({ message: "🔥 Internal Server Error", error: error.message });
  }
});


// 🔹 Delete an event
router.delete("/delete/:eventId", async (req, res) => {
  try {
    await Event.findByIdAndDelete(req.params.eventId);
    res.status(200).json({ message: "✅ Event deleted successfully!" });
  } catch (error) {
    res.status(500).json({ message: "🔥 Error deleting event", error: error.message });
  }
});


module.exports = router;
