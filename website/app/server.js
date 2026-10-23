const http = require("http");

const port = process.env.PORT || 8080;
const region = process.env.REGION_LABEL || "Unknown";

const server = http.createServer((req, res) => {
  if (req.url === "/health") {
    res.writeHead(200, { "Content-Type": "text/plain" });
    res.end("OK");
    return;
  }

  res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
  res.end(`
    <!DOCTYPE html>
    <html lang="de">
      <head>
        <meta charset="UTF-8">
        <title>Cloud Programming</title>
      </head>
      <body>
        <h1>Cloud Programming – Azure Deployment</h1>
        <p>Die Anwendung wurde erfolgreich in Microsoft Azure bereitgestellt.</p>
        <p><strong>Region:</strong> ${region}</p>
      </body>
    </html>
  `);
});

server.listen(port, () => {
  console.log(`Server läuft auf Port ${port}`);
});
