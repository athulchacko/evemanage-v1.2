const Attendee = require("../models/Attendee");
const Event = require("../models/Event");

// 📌 Register an Attendee
exports.registerAttendee = async (req, res) => {
  try {
    const { eventId, fullName, branchYear, email, phone, paymentProof } = req.body;

    // 🔹 Step 1: Validate input fields
    if (!eventId || !fullName || !branchYear || !email || !phone) {
      return res.status(400).json({ message: "⚠️ All fields are required." });
    }

    // 🔹 Step 2: Check if the event exists
    const event = await Event.findById(eventId);
    if (!event) {
      return res.status(404).json({ message: "⚠️ Event not found." });
    }

    // 🔹 Step 3: Assign `isPaid` from the event
    const isPaid = event.isPaid || true;

    // 🔹 Step 4: Enforce payment screenshot for paid events
    if (isPaid && (!paymentProof || paymentProof.trim() === "")) {
      return res.status(400).json({ message: "⚠️ Payment screenshot is required for paid events." });
    }

    // 🔹 Step 5: Check if the attendee is already registered
    const existingAttendee = await Attendee.findOne({ eventId, email });
    if (existingAttendee) {
      return res.status(400).json({ message: "⚠️ You are already registered for this event." });
    }

    // 🔹 Step 6: Register the attendee
    const newAttendee = new Attendee({
      eventId,
      fullName,
      branchYear,
      email,
      phone,
      isPaid,
      paymentProof: isPaid ? paymentProof : null, // Store only if required
    });

    await newAttendee.save();

    res.status(201).json({ message: "✅ Registration successful!" });

  } catch (error) {
    console.error("🔥 Error registering attendee:", error);
    res.status(500).json({ message: "🔥 Internal Server Error", error: error.message });
  }
};
