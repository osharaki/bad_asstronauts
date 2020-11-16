import WebSocket from 'ws';

const wss = new WebSocket.Server({ port: 3000 });

wss.addListener("listening", () => {
  console.log('WebSocket server running...');
});

wss.on('connection', () => {
  console.log('Connection received!');
});
