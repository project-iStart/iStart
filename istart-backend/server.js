const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const connectDB = require('./config/db');

dotenv.config();
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log("MongoDB connected"))
  .catch(err => {
    console.error(err);
    process.exit(1);
  });
  
const app = express();
app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PUT", "DELETE"],
}));app.use(express.json());

// Routes
app.use('/api/auth',          require('./routes/auth'));
app.use('/api/ideas',         require('./routes/ideas'));
app.use('/api/votes',         require('./routes/votes'));
app.use('/api/feedback',      require('./routes/feedback'));
app.use('/api/join-requests', require('./routes/joinRequests'));
app.use('/api/discussion',    require('./routes/discussion'));
app.use('/api/doc-requests',  require('./routes/docRequests'));
app.use('/api/notifications', require('./routes/notifications'));

app.get('/', (req, res) => res.send('iStart API Running'));

const PORT = process.env.PORT || 5000;
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on port ${PORT}`);
});