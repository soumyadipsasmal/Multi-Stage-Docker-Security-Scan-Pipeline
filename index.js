const express = require("express");
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Health check — Trivy & pipeline will hit this
app.get("/health", (req, res) => {
  res.status(200).json({
    status: "ok",
    timestamp: new Date().toISOString(),
    version: process.env.APP_VERSION || "1.0.0",
  });
});

app.get("/", (req, res) => {
  res.json({ message: "DevSecOps Demo App 🚀" });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app;
