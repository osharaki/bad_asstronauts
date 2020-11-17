import WebSocket from 'ws';
// const { v4: uuidv4 } = require('uuid'); // this import method disregards the type definitions installed from @types/uuid
import { v4 as uuidv4 } from 'uuid';

const wss = new WebSocket.Server({ port: 3000 });
const clients = []
wss.addListener("listening", () => {
  console.log('WebSocket server running...');
});

wss.on('connection', (ws) => {
  console.log('Connection received!');
  const uuid = uuidv4();
  clients.push({ uuid: ws });
  console.log(`Client ${uuid} added to list of clients!`);
  ws.send(uuid);
  ws.on('message', (msg) => {
    console.log(`Client  ${uuid} said: ${msg}`);
  });
});
