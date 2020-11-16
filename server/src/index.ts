import express = require('express');
const path = require('path');
import http = require('http');
// import { Socket } from 'socket.io';
let webSocketServer = require('websocket').server;

// Create a new express application instance
const app = express();
const server = http.createServer(app);
// const socket = require('socket.io')(server);

app.get('/', (req, res) => {
  res.send("Node Server is running");
});

server.listen(3000, function () {
  console.log('Example app listening on port 3000!');
});
let wsServer = new webSocketServer({ httpServer: server });

wsServer.on('request', (request: any) => {
  console.log('Connection received!');
  let connection = request.accept(null, request.origin);
  console.log(request.key);
});
