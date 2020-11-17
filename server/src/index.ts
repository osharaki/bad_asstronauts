import WebSocket from 'ws';
// const { v4: uuidv4 } = require('uuid'); // this import method disregards the type definitions installed from @types/uuid
import { v4 as uuidv4 } from 'uuid';

const boxPos = { posX: 50, posY: 50 };

const wss = new WebSocket.Server({ port: 3000 });
// const clients = [];
wss.addListener("listening", () => {
  console.log('WebSocket server running...');
});

wss.on('connection', ws => {

  if (wss.clients.size == 1) {
    console.log('1st connection received!');
  }
  else { console.log(`Connection number ${wss.clients.values.length} received!`); }
  ws.send(JSON.stringify(boxPos));
  // const uuid = uuidv4();
  // clients.push({ uuid: ws });
  // console.log(`Client ${uuid} added to list of clients!`);
  // ws.send(uuid);
  ws.on('message', (msg: string) => {
    // console.log(`Client  ${uuid} said: ${msg}`);
    console.log(`Client said: ${msg}`);
    const data = JSON.parse(msg);
    if (data.action == 'New pos') {
      console.log('New position requested');
      generateRandomPos();
      console.log(`sending position ${JSON.stringify(boxPos)} to clients`);
      wss.clients.forEach(client => {
        client.send(JSON.stringify(boxPos));
      });
    }
  });
  ws.on('close', reason => {
    // TODO doesn't detect broken connections. See https://www.npmjs.com/package/ws#how-to-detect-and-close-broken-connections
    console.log('Client disconneted!');
  });
});

function generateRandomPos() {
  const posX = Math.random() * 100;
  const posY = Math.random() * 100;
  boxPos['posX'] = posX;
  boxPos['posY'] = posY;
}