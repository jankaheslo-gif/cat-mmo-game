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
  players[socket.id] = { position: { x: Math.random()*10 - 5, y: 0, z: Math.random()*10 - 5 }, rotation: 0, name: 'Unknown' };
  console.log('Players after connect:', Object.keys(players));

  // Send init with player ID
  socket.emit('init', { id: socket.id });

  // Broadcast new player to all others
  socket.broadcast.emit('playerJoined', { id: socket.id, state: players[socket.id] });

  // Send current world state to new client
  socket.emit('worldState', players);

  socket.on('command', (data) => {
    console.log('Received command from', socket.id, ':', data);
    if (players[socket.id]) {
      players[socket.id] = { ...players[socket.id], ...data };
      console.log('Updated players:', players);
    }
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
    delete players[socket.id];
    console.log('Players after disconnect:', Object.keys(players));
    // Broadcast removal
    io.emit('playerLeft', { id: socket.id });
  });
});

// Fixed 20Hz game tick for server authority
setInterval(() => {
  io.emit('worldState', players);
  console.log('World state broadcast');
}, 50);