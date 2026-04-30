const fs = require('fs');
const path = require('path');
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: '*' } });

const publicPathCandidate = path.join(__dirname, 'public');
const fallbackPublicPath = path.join(__dirname, 'cat-mmo', 'public');
const publicPath = fs.existsSync(publicPathCandidate)
  ? publicPathCandidate
  : fs.existsSync(fallbackPublicPath)
  ? fallbackPublicPath
  : publicPathCandidate;

console.log('Using public path:', publicPath);

app.use(express.static(publicPath));

app.get('/', (req, res) => {
  const indexFile = path.join(publicPath, 'index.html');
  if (!fs.existsSync(indexFile)) {
    return res.status(500).send(`index.html not found at ${indexFile}`);
  }
  res.sendFile(indexFile);
});

const players = new Map();

io.on('connection', (socket) => {
  console.log('Cat connected:', socket.id);
  players.set(socket.id, { tile: "T50005000", rotation: 0 });

  socket.emit('init', { id: socket.id, tile: "T50005000" });

  socket.on('command', (data) => {
    io.emit('worldUpdate', {
      playerId: socket.id,
      cmd: data.cmd,
      tile: data.tile || "T50005000",
      obj: data.obj,
      timestamp: Date.now()
    });
  });

  socket.on('disconnect', () => {
    players.delete(socket.id);
    console.log('Cat left:', socket.id);
  });
});

server.listen(3000, () => console.log('✅ Server running → http://localhost:3000'));