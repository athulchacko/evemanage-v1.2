const mongoose = require("mongoose");
const Vendor = require("./models/Vendor");

// ✅ MongoDB Atlas Connection String (Replace <your_connection_string>)
mongoose.connect("mongodb+srv://athulchacko221:athul123456@evemanage.eym6k.mongodb.net/", ).then(() => {
  console.log("✅ Connected to MongoDB Atlas");
}).catch(err => {
  console.error("🔥 MongoDB Connection Error:", err);
});

const vendors = [
  { name: "Elite Caterers", location: "Trivandrum", contact: "+91 9876543210", category: "Catering", rating: 4.8 },
  { name: "Delicious Bites", location: "Kochi", contact: "+91 9876543288", category: "Catering", rating: 4.7 },
  { name: "Gourmet Feast", location: "Kollam", contact: "+91 9876543299", category: "Catering", rating: 4.9 },

  { name: "Sound Blasters", location: "Pappanamcode", contact: "+91 9876543222", category: "Lights & Sound", rating: 4.7 },
  { name: "Audio Visual Pros", location: "Kochi", contact: "+91 9876543300", category: "Lights & Sound", rating: 4.8 },
  { name: "Event Sound Experts", location: "Kollam", contact: "+91 9876543311", category: "Lights & Sound", rating: 4.9 },

  { name: "Floral Decorators", location: "Ernakulam", contact: "+91 9876543233", category: "Decorations", rating: 4.6 },
  { name: "Elegant Blooms", location: "Trivandrum", contact: "+91 9876543322", category: "Decorations", rating: 4.7 },
  { name: "Royal Florists", location: "Kollam", contact: "+91 9876543333", category: "Decorations", rating: 4.8 },

  { name: "Mega Tents", location: "Velayani", contact: "+91 9876543244", category: "Tent & Stage Setup", rating: 4.9 },
  { name: "Event Structures", location: "Kochi", contact: "+91 9876543344", category: "Tent & Stage Setup", rating: 4.7 },
  { name: "Stage Masters", location: "Kollam", contact: "+91 9876543355", category: "Tent & Stage Setup", rating: 4.8 },

  { name: "Event Photographers", location: "Nemom", contact: "+91 9876543255", category: "Photography", rating: 4.5 },
  { name: "Lens Masters", location: "Kochi", contact: "+91 9876543366", category: "Photography", rating: 4.7 },
  { name: "Shutter Pros", location: "Kollam", contact: "+91 9876543377", category: "Photography", rating: 4.8 },

  { name: "DJ Beats", location: "Karakkamadapam", contact: "+91 9876543266", category: "Music & DJ", rating: 4.7 },
  { name: "Party Mix DJs", location: "Kochi", contact: "+91 9876543388", category: "Music & DJ", rating: 4.8 },
  { name: "Groove Masters", location: "Kollam", contact: "+91 9876543399", category: "Music & DJ", rating: 4.9 },

  { name: "Royal Security", location: "Killipalam", contact: "+91 9876543277", category: "Security Services", rating: 4.8 },
  { name: "Event Guards", location: "Kochi", contact: "+91 9876543400", category: "Security Services", rating: 4.7 },
  { name: "Safe Hands", location: "Kollam", contact: "+91 9876543411", category: "Security Services", rating: 4.9 }
];

// ✅ Insert Vendors
Vendor.insertMany(vendors)
  .then(() => {
    console.log("✅ Vendors inserted successfully!");
    mongoose.connection.close();
  })
  .catch(error => {
    console.error("🔥 Error inserting vendors:", error);
    mongoose.connection.close();
  });
