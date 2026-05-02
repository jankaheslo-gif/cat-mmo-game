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

  socket.emit('init', { id: socket.id });
  console.log('Sent init to', socket.id);

  socket.broadcast.emit('playerJoined', { id: socket.id, state: players[socket.id] });
  console.log('Broadcasted playerJoined for', socket.id);

  socket.emit('worldUpdate', players);
  console.log('Sent worldUpdate to', socket.id, 'with players:', players);

  socket.on('command', (data) => {
    console.log('Received command from', socket.id, ':', data);
    if (players[socket.id]) {
      players[socket.id] = { ...players[socket.id], ...data };
      console.log('Updated players:', players);
    }
    io.emit('worldUpdate', players);
    console.log('Broadcasted worldUpdate to all');
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
    delete players[socket.id];
    console.log('Players after disconnect:', Object.keys(players));
    socket.broadcast.emit('playerLeft', { id: socket.id });
    console.log('Broadcasted playerLeft for', socket.id);
  });
});

server.listen(process.env.PORT || 3000, () => {
  console.log('Server running on port', process.env.PORT || 3000);
});

// Periodic world sync
setInterval(() => {
  io.emit('worldUpdate', players);
  console.log('Periodic worldUpdate sent');
}, 200);