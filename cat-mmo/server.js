const express = require('express');
const http = require('http');
const socketIo = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

app.use(express.static('public'));

let players = {}; // Shared player state: { id: { position, rotation, ... } }

io.on('connection', (socket) => {
  console.log('A user connected:', socket.id);

  // Initialize new player with default state
  players[socket.id] = { position: { x: 0, y: 0, z: 0 }, rotation: 0 };

  // Send init with player ID
  socket.emit('init', { id: socket.id });

  // Broadcast new player to others
  socket.broadcast.emit('playerJoined', { id: socket.id, state: players[socket.id] });

  // Send current players to new player
  socket.emit('worldUpdate', players);

  socket.on('command', (data) => {
    // Update local player state (assume data has position/rotation updates)
    if (players[socket.id]) {
      players[socket.id] = { ...players[socket.id], ...data };
    }
    // Broadcast updated world state to all clients
    io.emit('worldUpdate', players);
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
    delete players[socket.id];
    // Broadcast removal
    socket.broadcast.emit('playerLeft', { id: socket.id });
  });
});

server.listen(process.env.PORT || 3000, () => {
  console.log('Server running on port', process.env.PORT || 3000);
});