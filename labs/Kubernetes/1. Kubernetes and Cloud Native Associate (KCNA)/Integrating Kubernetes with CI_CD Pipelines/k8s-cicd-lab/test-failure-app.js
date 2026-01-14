const express = require('express');
const app = express();
const port = 3000;

// Intentionally broken code
app.get('/', (req, res) => {
  // This will cause an error
  nonExistentFunction();
  res.json({
    message: 'This version is broken!',
    version: '2.0.0'
  });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`App running on port ${port}`);
});
