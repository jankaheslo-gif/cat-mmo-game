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
  
  players.set(socket.id, { 
    id: socket.id,
    tile: "T50005000", 
    rotation: 0,
    x: 0, 
    z: 0 
  });

  // Send init to new player
  socket.emit('init', { id: socket.id, tile: "T50005000" });

  // Send all existing players to new player
  const existingPlayers = Array.from(players.values());
  socket.emit('worldState', { players: existingPlayers });

  // Broadcast new player to others
  socket.broadcast.emit('playerJoined', players.get(socket.id));

  socket.on('command', (data) => {
    const player = players.get(socket.id);
    if (player && data.tile) {
      player.tile = data.tile;
      player.x = parseFloat(data.tile.substring(1, 5)) || 0; // rough parse
      player.z = parseFloat(data.tile.substring(5)) || 0;
    }

    io.emit('worldUpdate', {
      playerId: socket.id,
      cmd: data.cmd,
      tile: data.tile,
      timestamp: Date.now()
    });
  });

  socket.on('disconnect', () => {
    players.delete(socket.id);
    io.emit('playerLeft', { id: socket.id });
    console.log('Cat left:', socket.id);
  });
});

// Broadcast full world state every 150ms
setInterval(() => {
  const state = Array.from(players.values());
  io.emit('worldState', { players: state });
}, 150);

server.listen(3000, () => console.log('✅ Server running → http://localhost:3000'));