import express = require('express');
const path = require('path');
import http = require('http');
import { Socket } from 'socket.io';


// Create a new express application instance
const app = express();
const server = http.createServer(app);
const socketio = require('socket.io')(server);

app.get('/', (req, res) => {
  res.send("Node Server is running. Yay!!")
});

server.listen(3000, function () {
  console.log('Example app listening on port 3000!');
});

socketio.on("connection", (socket: Socket) => {
  console.log(`connect ${socket.id}`);
  console.log(`connect ${socket.handshake.url}`);
  
  socket.on("disconnect", () => {
    console.log(`disconnect ${socket.id}`);
  });
});
