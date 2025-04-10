const nodemailer = require("nodemailer");
require("dotenv").config();
const { BASE_URL } = require("../config/config"); // Import BASE_URL from config


const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: process.env.SMTP_PORT,
  secure: process.env.SMTP_PORT === "465", // Use true for port 465 (SSL/TLS), false otherwise
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

// ✅ Function to send approval email with a join link
const sendApprovalEmail = async (toEmail, eventName, eventId) => {
  // Generate the join link
    const joinLink = `${BASE_URL}/api/events/join/${eventId}`;

  // Validate email address
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(toEmail)) {
    console.error(`❌ Invalid email address: ${toEmail}`);
    throw new Error("Invalid email address");
  }

  const mailOptions = {
    from: `"Event Manager" <${process.env.SMTP_USER}>`,
    to: toEmail,
    subject: `✅ Your Event "${eventName}" is Approved!`,
    html: `
      <h2>🎉 Congratulations!</h2>
      <p>Your event <strong>${eventName}</strong> has been approved.</p>
      <p>🔗 <b>Join Link for Attendees:</b> <a href="${joinLink}" target="_blank">${joinLink}</a></p>
      <p>📧 Please share this link with your attendees.</p>
      <hr>
      <p>Thank you for using our platform! 🚀</p>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log(`📧 Email sent successfully to ${toEmail}`);
  } catch (error) {
    console.error(`❌ Failed to send email to ${toEmail}: ${error.message}`);
    throw error;
  }
};

// ✅ Export the function
module.exports = { sendApprovalEmail };
