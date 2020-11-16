import express = require('express');
const path = require('path');
import http = require('http');
import { Socket } from "socket.io";

const socketio = require('socket.io');

// Create a new express application instance
const app: express.Application = express();
const server = http.createServer(app);
const io = socketio(server);


app.use(express.static('C:\\Users\\osharaki\\programming_misc_local\\Flutter\\game-off-2020\\server\\public'));
server.listen(3000, function () {
  console.log('Example app listening on port 3000!');
});

io.on("connection", (socket: Socket) => {
  console.log(`connect ${socket.id}`);

  socket.on("disconnect", () => {
    console.log(`disconnect ${socket.id}`);
  });
});
