const mongoose = require("mongoose");

const AttendeeSchema = new mongoose.Schema(
  {
    eventId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Event",
      required: true,
    },
    name: {
      type: String,
      required: true,
    },
    branchCode: {
      type: String,
      required: true,
    },
    email: {
      type: String,
      required: true,
      unique: false, // Allow multiple registrations with the same email for different events
    },
    phone: {
      type: String,
      required: true,
      validate: {
        validator: function (v) {
          return /^\d{10}$/.test(v); // Validate phone number (10 digits)
        },
        message: (props) => `${props.value} is not a valid phone number!`,
      },
    },
    isPaid: {
      type: Boolean,
      required: false, // Ensure this field is always required
    },
    paymentProof: {
      type: String, // Base64 or file path
      default: null,
    },
    registeredAt: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Attendee", AttendeeSchema);
