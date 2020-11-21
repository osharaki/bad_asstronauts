import WebSocket from 'ws';
import { v4 as uuidv4 } from 'uuid';

const wss = new WebSocket.Server({ port: 3000 });

wss.addListener("listening", () => {
  console.log('WebSocket server running...');
});

var serverData = {
  "players": {},
  "sessions": {
    "test":{
      "players":{}
    }
  },
  "assets": {}
};

function generateID() {
  var id = '';
  var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  var charactersLength = characters.length;

  for ( var i = 0; i < 10; i++ ) {
    id += characters.charAt(Math.floor(Math.random() * charactersLength));
  }

  return id;
}

wss.on('connection', ws => {
  // Add player to server
  connectPlayer( ws, wss );
  
  ws.on('message', ( rawMessage: string ) => {
    // Extract data
    var message = JSON.parse( rawMessage );
    var action = message[ "action" ];
    var data = message[ "data" ];

    if ( action == 'join' ) {
      console.log(`Client ${ws[ "id" ]} joining session ${data[ "session" ]}`);

      // Add session in player and player in session
      addPlayerToSpecificSession( ws[ "id" ], data[ "session" ] );
    }
  });

  ws.on('close', reason => {
    // TODO doesn't detect broken connections. See https://www.npmjs.com/package/ws#how-to-detect-and-close-broken-connections
        
    // Remove player from session
    removePlayerFromAnySession( ws[ "id" ] );

    // Remove player from server
    disconnectPlayer( ws[ "id" ] )
    
  });
});

function connectPlayer( websocket, server ) {
  // Generate, Store, & Send Client ID
  var clientID = generateID();
  websocket["id"] = clientID;
  serverData[ "players" ][ clientID ] = {
    "session": null,
    "websocket": websocket
  };
  
  var connectMessage = { "action": "connect", "data": { "id":clientID } }

  websocket.send( JSON.stringify( connectMessage ) )

  // Print
  console.log(`Connected Client: ${clientID}`);
  console.log( `Total Clients: ${server.clients.size}` )
  console.log( `Total Players: ${Object.keys( serverData[ "players" ] ).length}` )
}

function disconnectPlayer( player ) {
  // Remove player from server
  delete serverData[ "players" ][ player ];

  // Print
  console.log(`Disconnected Client: ${player}`);
  console.log( `Total Clients: ${wss.clients.size}` );
  console.log( `Total Players: ${Object.keys( serverData[ "players" ] ).length}` );
}

function addPlayerToSpecificSession( player, session ) {
  // Initial Data to assign player
  var initData = {
    "spaceship": {
      "position": [ null, null ],
      "angle": null
    }
  };

  // Add session in player and player in session
  serverData[ "players" ][ player ][ "session" ] = session;
  serverData[ "sessions" ][ session ][ "players" ][ player ] = initData;

  // Send player join information
  sendMessageToPlayer( player, action="join", data=initData );

  // Send the updated session information to all players in the session
  updateSession( session );

  // Print
  console.log( `Added player ${player} to session ${session}` );
}

function removePlayerFromAnySession( player ) {
  var session = serverData[ "players" ][ player ][ "session" ];

  // Remove player from session
  if ( session != null ) {
    delete serverData[ "sessions" ][ session ][ "players" ][ player ];

    // Send the updated session information to all players in the session
    updateSession( session );

    // Print
    console.log( `Removed player ${player} from session ${session}` );
  }
}

function removePlayerFromSpecificSession( player, session ) {
  var players = serverData[ "sessions" ][ session ][ "players" ];
  
  // Remove player from session
  if ( player in players ) {
    delete serverData[ "sessions" ][ session ][ "players" ][ player ];
    
    // Send the updated session information to all players in the session
    updateSession( session );

    // Print
    console.log( `Removed player ${player} from session ${session}` );
  }
}

function sendMessageToPlayer( player, action='', data={}, message='' ) {
  // Create Message
  if ( message === '' ) {
    message = compileMessage( action, data );
  }

  // Get WebSocket
  var playerWebSocket = serverData[ "players" ][ player ][ "websocket" ];

  // Send
  playerWebSocket.send( message );

  // Print
  console.log(`Sent data to player ${player}`);
}

function sendMessageToSession( session, action='', data='', message='' ) {
  // Create Message
  if ( message === '' ) {
    message = compileMessage( action, data );
  }

  var players = serverData[ "sessions" ][ session ][ "players" ];
  
  // Send message to all players in the session
  Object.keys( players ).forEach( player => {
    sendMessageToPlayer( player, message=message );
  });
  
  // Print
  console.log(`Updated players in session ${session}`);
}

function compileMessage( action, data ) {
  // Compile Message
  var message = { "action": action, "data": data };
  var encodedMessage = JSON.stringify( message );

  return encodedMessage;
}

function updateSession( session ) {
  // Send the updated session information to all players in the session
  sendMessageToSession( session, action="update", data=serverData[ "sessions" ][ session ] );

  // Print
  console.log(`Updated players in session ${session}`);
}