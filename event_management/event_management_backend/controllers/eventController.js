const Event = require("../models/Event");
const Attendee = require("../models/Attendee");

// ✅ Create Event (with Conflict Checking)
exports.createEvent = async (req, res) => {
  try {
    const {
      eventName,
      location,
      startDate, // Format: "YYYY-MM-DD"
      endDate,   // Format: "YYYY-MM-DD"
      startTime, // Format: "HH:MM"
      endTime,   // Format: "HH:MM"
      description,
      createdBy,
      isPaid,
      idCardImage,
      thumbnailImage
    } = req.body;

    // 🔹 Validate required fields
    if (!eventName || !location || !startDate || !startTime || !endDate || !endTime) {
      return res.status(400).json({ error: "⚠️ Missing required fields: eventName, location, startDate, startTime, endDate, or endTime" });
    }

    // 🔹 Convert to full Date-Time objects
    const eventStart = new Date(`${startDate}T${startTime}:00.000Z`);
    const eventEnd = new Date(`${endDate}T${endTime}:00.000Z`);

    if (eventEnd <= eventStart) {
      return res.status(400).json({ error: "⚠️ Event end time must be after start time." });
    }

    // 🔹 Log request data (debugging)
    console.log("📌 Received Event Data:", { eventStart, eventEnd });

    // 🔹 Check for conflicting events at the same location
    const conflictingEvent = await Event.findOne({
      location,
      status: { $in: ["pending", "approved"] }, // Ignore canceled/rejected events
      $or: [
        // Check if the new event overlaps an existing event
        {
          eventStart: { $lt: eventEnd }, 
          eventEnd: { $gt: eventStart }
        }
      ]
    });

    if (conflictingEvent) {
      return res.status(400).json({
        error: "⚠️ Conflict: Another event is already scheduled at this time and location.",
        conflictingEvent: {
          eventName: conflictingEvent.eventName,
          eventStart: conflictingEvent.eventStart,
          eventEnd: conflictingEvent.eventEnd
        }
      });
    }

    // ✅ No conflicts - Create new event
    const newEvent = new Event({
      eventName,
      location,
      eventStart,
      eventEnd,
      description,
      createdBy,
      isPaid,
      idCardImage,
      thumbnailImage,
      status: "pending",
      approved: false
    });

    await newEvent.save();

    res.status(201).json({
      message: "✅ Event created successfully! Awaiting admin approval.",
      event: newEvent
    });

  } catch (error) {
    console.error("🔥 Error creating event:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// ✅ Approve Event (Admin Action)
exports.approveEvent = async (req, res) => {
  try {
    const { eventId } = req.params;

    const event = await Event.findById(eventId);
    if (!event) return res.status(404).json({ error: "Event not found" });

    if (event.approved) {
      return res.status(400).json({ error: "Event is already approved" });
    }

    // Approve event and generate join link
    event.approved = true;
    event.status = "approved";
    event.joinLink = `https://yourapp.com/join/${event._id}`;

    await event.save();
    res.status(200).json({ message: "✅ Event approved", joinLink: event.joinLink });

  } catch (error) {
    console.error("🔥 Error approving event:", error);
    res.status(500).json({ error: "Server error" });
  }
};

// ✅ Join Event (Attendee uploads payment proof if required)
exports.joinEvent = async (req, res) => {
  try {
    const { eventId, attendeeName, attendeeEmail, paymentProof } = req.body;

    const event = await Event.findById(eventId);
    if (!event) return res.status(404).json({ error: "Event not found" });
    if (!event.approved) return res.status(400).json({ error: "Event is not approved yet" });

    if (event.isPaid && !paymentProof) {
      return res.status(400).json({ error: "Payment proof is required for paid events" });
    }

    const newAttendee = new Attendee({
      eventId,
      attendeeName,
      attendeeEmail,
      paymentProof: event.isPaid ? paymentProof : null,
    });

    await newAttendee.save();
    res.status(201).json({ message: "✅ Joined event successfully", attendeeId: newAttendee._id });

  } catch (error) {
    console.error("🔥 Error joining event:", error);
    res.status(500).json({ error: "Server error" });
  }
};
