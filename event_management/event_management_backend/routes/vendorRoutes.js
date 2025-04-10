const express = require("express");
const router = express.Router();
const Vendor = require("../models/Vendor"); // Ensure you have a Vendor model

// ✅ Get all vendors
router.get("/", async (req, res) => {
  try {
    const vendors = await Vendor.find();
    res.json(vendors);
  } catch (error) {
    res.status(500).json({ message: "🔥 Error fetching vendors", error });
  }
});

// ✅ API to fetch vendors grouped by category
router.get("/vendors", async (req, res) => {
  try {
    const vendors = await Vendor.find();

    // Group vendors by category
    const groupedVendors = vendors.reduce((acc, vendor) => {
      const category = vendor.category || "Others"; // Default to "Others" if category is missing
      if (!acc[category]) {
        acc[category] = [];
      }
      acc[category].push(vendor);
      return acc;
    }, {});

    res.status(200).json(groupedVendors);
  } catch (error) {
    console.error("🔥 Error fetching vendors:", error);
    res.status(500).json({ error: "Failed to fetch vendors" });
  }
});

module.exports = router;
