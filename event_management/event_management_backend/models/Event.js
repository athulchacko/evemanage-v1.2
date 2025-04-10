const mongoose = require("mongoose");

// ✅ Attendee Schema
const attendeeSchema = new mongoose.Schema({
  name: { type: String, required: true },
  branchCode: { type: String, default: null }, // Optional branch code
  email: {
    type: String,
    required: true,
    validate: {
      validator: function (v) {
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v); // Validate email format
      },
      message: (props) => `${props.value} is not a valid email address!`,
    },
  },
  phone: { type: String, default: null }, // Optional phone number
  paymentProof: { type: String, default: null }, // Base64 payment proof (only for paid events)
});

// ✅ Event Schema
const eventSchema = new mongoose.Schema(
  {
    eventName: { type: String, required: true },
    location: { type: String, required: true }, // Ensure location is required
    startDate: {
      type: Date,
      required: true,
      validate: {
        validator: isValidDate,
        message: "Invalid start date",
      },
    },
    endDate: {
      type: Date,
      required: true,
      validate: [
        { validator: isValidDate, message: "Invalid end date" },
        {
          validator: function (value) {
            return value > this.startDate; // Ensure endDate is after startDate
          },
          message: "End date must be after start date",
        },
      ],
    },
    startTime: { type: String, required: true },
    endTime: { type: String, required: true },
    description: { type: String, default: "" }, // Optional description
    createdBy: { type: String, required: true }, // User ID or Firebase UID
    isPaid: { type: Boolean, default: false }, // Default to free event
    eventThumbnail: { type: String,required: false }, // Base64 or URL
    idCardImage: { type: String, required: true }, // Base64 or URL
    status: {
      type: String,
      enum: ["pending", "approved", "rejected"],
      default: "pending",
    },
    joinLink: { type: String, default: null }, // Generated after approval
    attendees: { type: [attendeeSchema], default: [] }, // Array of attendees
  },
  { timestamps: true }
);

// ✅ Function to check if a date is valid
function isValidDate(value) {
  return !isNaN(Date.parse(value));
}

// ✅ Conflict-Checking Middleware Before Saving
eventSchema.pre("save", async function (next) {
  try {
    // Validate dates before proceeding
    if (!this.startDate || !this.endDate || isNaN(this.startDate) || isNaN(this.endDate)) {
      return next(new Error("⚠️ Invalid startDate or endDate."));
    }

    const Event = mongoose.model("Event");

    // 🔹 Check for event conflicts (overlapping time ranges at the same location)
    const existingEvent = await Event.findOne({
      location: this.location,
      _id: { $ne: this._id }, // ✅ Exclude the current event itself
      $or: [
        // Check for overlapping events
        { startDate: { $lt: this.endDate }, endDate: { $gt: this.startDate } },
      ],
    });

    if (existingEvent) {
      return next(
        new Error(
          `⚠️ Event conflict! Another event "${existingEvent.eventName}" is already scheduled at ${existingEvent.location} from ${existingEvent.startDate.toISOString()} to ${existingEvent.endDate.toISOString()}.`
        )
      );
    }

    next();
  } catch (error) {
    console.error("🔥 Error in pre-save middleware:", error);
    next(error);
  }
});

// ✅ Export the model
module.exports = mongoose.model("Event", eventSchema);
