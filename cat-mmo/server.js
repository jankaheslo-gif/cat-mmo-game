const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: "*" } });

// Disable caching for development
app.use((req, res, next) => {
  res.set('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0');
  res.set('Pragma', 'no-cache');
  res.set('Expires', '0');
  next();
});

// IMPORTANT: Serve the public folder + root route
app.use(express.static('public'));

app.get('/', (req, res) => {
  res.sendFile(__dirname + '/public/index.html');
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