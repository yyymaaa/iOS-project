import express from "express";
import axios from "axios";
import dotenv from "dotenv";
dotenv.config();

const app = express();
app.use(express.json());

const {
    CONSUMER_KEY,
    CONSUMER_SECRET,
    SHORTCODE,
    PASSKEY,
    CALLBACK_URL,
    PORT
} = process.env;

// Generate access token
app.get("/token", async (req, res) => {
    const auth = Buffer.from(`${CONSUMER_KEY}:${CONSUMER_SECRET}`).toString("base64");
    try {
        const response = await axios.get(
            "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials",
            { headers: { Authorization: `Basic ${auth}` } }
        );
        res.json(response.data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// STK Push route
app.post("/stkpush", async (req, res) => {
    const { phoneNumber, amount } = req.body;
    
    // Format phone number correctly
    const formattedPhone = `254${phoneNumber}`;
    
    console.log("Received request:", { phoneNumber, amount, formattedPhone });
    
    try {
        // 1. Get access token
        const auth = Buffer.from(`${CONSUMER_KEY}:${CONSUMER_SECRET}`).toString("base64");
        const tokenResponse = await axios.get(
            "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials",
            { headers: { Authorization: `Basic ${auth}` } }
        );
        const accessToken = tokenResponse.data.access_token;
        
        // 2. Prepare STK Push payload
        const timestamp = new Date()
            .toISOString()
            .replace(/[-:TZ.]/g, "")
            .slice(0, 14);
        const password = Buffer.from(`${SHORTCODE}${PASSKEY}${timestamp}`).toString("base64");
        
        const stkData = {
            BusinessShortCode: SHORTCODE,
            Password: password,
            Timestamp: timestamp,
            TransactionType: "CustomerPayBillOnline",
            Amount: Math.round(amount), // an integer
            PartyA: formattedPhone,  // formatted phone
            PartyB: SHORTCODE,
            PhoneNumber: formattedPhone,  // formatted phone
            CallBackURL: CALLBACK_URL,
            AccountReference: "TestOrder",
            TransactionDesc: "Test Payment",
        };
        
        console.log("Sending STK Push:", stkData);
        
        // 3. Send STK push request
        const stkResponse = await axios.post(
            "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest",
            stkData,
            { headers: { Authorization: `Bearer ${accessToken}` } }
        );
        
        console.log("STK Response:", stkResponse.data);
        res.json({ success: true, response: stkResponse.data });
        
    } catch (error) {
        console.error("Error:", error.response?.data || error.message);
        res.status(500).json({
            success: false,
            message: error.response?.data || error.message,
        });
    }
});

// Callback endpoint to receive M-Pesa responses
app.post("/callback", (req, res) => {
    console.log("M-Pesa Callback received:", JSON.stringify(req.body, null, 2));
    res.json({ success: true });
});

// Start server
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));