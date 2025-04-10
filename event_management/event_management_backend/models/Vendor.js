const mongoose = require("mongoose");

const vendorSchema = new mongoose.Schema({
  name: String,
  location: String,
  contact: String,
  category: String,
  rating: Number
});

const Vendor = mongoose.model("Vendor", vendorSchema);
module.exports = Vendor;
