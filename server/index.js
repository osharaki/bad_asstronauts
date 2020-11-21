const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 3000 });

wss.addListener('listening', () => {
  console.log('WebSocket server running...');
});

var serverData = {
  'players': {},
  'sessions': {
    'test':{
      'players':{}
    }
  },
  'assets': {}
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
  
  ws.on('message', ( rawMessage ) => {
    // Extract data
    var message = JSON.parse( rawMessage );
    var action = message[ 'action' ];
    var data = message[ 'data' ];

    if ( action == 'join' ) {
      // Add session in player and player in session
      addPlayerToSpecificSession( ws[ 'id' ], data[ 'session' ] );
    } else if ( action == 'update' ) {
      var session = serverData[ 'players' ][ ws[ 'id' ] ];
      serverData[ 'sessions' ][ session ] = data;
      updateSession( session );
    }
  });

  ws.on('close', reason => {
    // TODO doesn't detect broken connections. See https://www.npmjs.com/package/ws#how-to-detect-and-close-broken-connections
        
    // Remove player from session
    removePlayerFromAnySession( ws[ 'id' ] );

    // Remove player from server
    disconnectPlayer( ws[ 'id' ] )
    
  });
});

function connectPlayer( websocket, server ) {
  // Generate, Store, & Send Client ID
  var clientID = generateID();
  websocket['id'] = clientID;
  serverData[ 'players' ][ clientID ] = {
    'session': null,
    'websocket': websocket
  };
  
  sendMessageToPlayer( 'connect', { 'id':clientID }, clientID );

  // Print
  console.log(`Connected Client: ${clientID}`);
  console.log( `Total Clients: ${server.clients.size}` )
  console.log( `Total Players: ${Object.keys( serverData[ 'players' ] ).length}` )
}

function disconnectPlayer( player ) {
  // Remove player from server
  delete serverData[ 'players' ][ player ];

  // Print
  console.log(`Disconnected Client: ${player}`);
  console.log( `Total Clients: ${wss.clients.size}` );
  console.log( `Total Players: ${Object.keys( serverData[ 'players' ] ).length}` );
}

function addPlayerToSpecificSession( player, session ) {
  if ( serverData[ 'players' ][ player ][ 'session' ] != session ) {
    // Initial Data to assign player
    var initData = {
      'spaceship': {
        'position': [ 0, 0 ],
        'angle': 0
      }
    };

    // Add session in player and player in session
    serverData[ 'players' ][ player ][ 'session' ] = session;
    serverData[ 'sessions' ][ session ][ 'players' ][ player ] = initData;

    // Send player join information
    // sendMessageToPlayer( player, action='join', data=initData );

    // Send the updated session information to all players in the session
    updateSession( session );

    // Print
    console.log( `Added player ${player} to session ${session}` );
  }
}

function removePlayerFromAnySession( player ) {
  var session = serverData[ 'players' ][ player ][ 'session' ];

  // Remove player from session
  if ( session != null ) {
    delete serverData[ 'sessions' ][ session ][ 'players' ][ player ];

    // Send the updated session information to all players in the session
    updateSession( session );

    // Print
    console.log( `Removed player ${player} from session ${session}` );
  }
}

function removePlayerFromSpecificSession( player, session ) {
  var players = serverData[ 'sessions' ][ session ][ 'players' ];
  
  // Remove player from session
  if ( player in players ) {
    delete serverData[ 'sessions' ][ session ][ 'players' ][ player ];
    
    // Send the updated session information to all players in the session
    updateSession( session );

    // Print
    console.log( `Removed player ${player} from session ${session}` );
  }
}

function sendMessageToPlayer( action, data, player ) {
  // Create Message
  message = compileMessage( action, data );

  // Get WebSocket
  var playerWebSocket = serverData[ 'players' ][ player ][ 'websocket' ];

  // Send
  playerWebSocket.send( message );

  // Print
  console.log(`Sent message to player ${player}`);
}

function sendMessageToSession( action, data, session ) {
  var players = serverData[ 'sessions' ][ session ][ 'players' ];
  
  // Send message to all players in the session
  Object.keys( players ).forEach( player => {
    sendMessageToPlayer( action, data, player );
  });
  
  // Print
  console.log(`Updated players in session ${session}`);
}

function compileMessage( action, data ) {
  // Compile Message
  var message = { 'action': action, 'data': data };
  var encodedMessage = JSON.stringify( message );

  return encodedMessage;
}

function updateSession( session ) {
  // Send the updated session information to all players in the session
  sendMessageToSession(
    'update',
    serverData[ 'sessions' ][ session ],
    session
  );

  // Print
  console.log(`Updated players in session ${session}`);
}