const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 3000 });

wss.addListener('listening', () => {
  console.log('WebSocket server running...');
});

var serverData = {
  'players': {},
  'sessions': {},
  'assets': {}
};

setInterval( updateTime, 1000 );

wss.on( 'connection', ws => {
  // Add player to server
  connectPlayer( ws, wss );
  
  ws.on( 'message', ( rawMessage ) => {
    // Get Player info
    var player = ws[ "id" ];
    var session = serverData[ "players" ][ player ][ "session" ];

    // Extract data from message
    var message = JSON.parse( rawMessage );
    var action = message[ 'action' ];
    var data = message[ 'data' ];

    if ( action == 'join' ) {
      var session = data[ "session" ];
      if ( session in serverData[ "sessions" ] ) {
        // If session exists, add session in player and player in session
        addPlayerToSpecificSession( player, session );

      } else {
        sendMessageToPlayer( "wrongSession", null, player );
      }
      
    } else if ( action == 'update' ) {
      serverData[ 'sessions' ][ session ] = data;
      updateSession( session );
      
    } else if ( action == "leave" ) {
      if ( player == serverData[ "sessions" ][ session ][ "host" ] ) {
        endSession( session );

      } else {
        removePlayerFromSpecificSession( player, data[ "session" ] );
      }
      
    } else if ( action == "updateSpaceship" ) {
      serverData[ "sessions" ][ session ][ "players" ][ player ][ "spaceship" ] = data;
      updateSession( session );

    } else if ( action == "create" ) {
      createSession( data );

    } else if ( action == "joinRandom" ) {
      addPlayerToRandomSession( player );
    }
  });

  ws.on( 'close', reason => {
    // TODO doesn't detect broken connections. See https://www.npmjs.com/package/ws#how-to-detect-and-close-broken-connections

    // Get player info
    var player = ws[ "id" ];
        
    // Remove player from session
    removePlayerFromAnySession( player );

    // Remove player from server
    disconnectPlayer( player )
    
  });
});

function removeItemFromIterable( item, iterable ) {
  for ( var i = 0; i < iterable.length; i++ ) {
    if ( iterable[ i ] == item ) {
      iterable.splice( i, 1 );

      break;
    }
  }

  return iterable;
}

function generateID( length=10 ) {
  var id = '';
  var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  var charactersLength = characters.length;

  for ( var i = 0; i < length; i++ ) {
    id += characters.charAt( Math.floor( Math.random() * charactersLength ) );
  }

  return id;
}

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

function createSession( data ){
  var host = data[ "host" ];
  var session = generateID( 4 );

  serverData[ "sessions" ][ session ] = data;
  serverData[ "sessions" ][ session ][ "id" ] = session;

  addPlayerToSpecificSession( host, session );
  
  // sendMessageToPlayer( "createdSession", data, host );

  console.log(`Created Session: ${session}`);
}

function addPlayerToSpecificSession( player, session ) {
  // If player not in session and session not playing
  if ( ( serverData[ 'players' ][ player ][ 'session' ] != session )  && ( serverData[ "sessions" ][ session ][ "state" ] != "playing" ) ) {
    // Initial Data to assign player
    var initData = {
      "ready": false,
      'spaceship': {
        'position': [ 50, 50 ],
        'angle': 0
      },
      'planet': {
        "position": [ 50, 50 ]
      }
    };

    // Add session in player and player in session
    serverData[ 'players' ][ player ][ 'session' ] = session;
    serverData[ 'sessions' ][ session ][ 'players' ][ player ] = initData;

    // Inform session that player joined
    sendMessageToSession( "playerJoined", { "player": player, "info":serverData[ "sessions" ][ session ] }, session );
    
    // Print
    console.log( `Added player ${player} to session ${session}` );

    // Send latest information to session
    updateSession( session );

    // Send state updates to session
    updateSessionState( session );
  }
}

function fetchRandomSession() {
  var sessions = Object.keys( serverData[ "sessions" ] );
  var sessionCount = sessions.length;
  var foundSession = false;
  var count = 0;

  while ( count != sessionCount ) {
    // Add Count
    count += 1;

    // Pick Random Session
    var randomSessionIndex = Math.floor( Math.random() * sessions.length );
    var randomSession = sessions[ randomSessionIndex ];

    // Remove Session from Sessions, so next iteration we don't pick it again
    sessions = removeItemFromIterable( randomSession, sessions );

    // Join session if waiting
    if ( serverData[ "sessions" ][ randomSession ][ "state" ] == "waiting" ) {
      foundSession = randomSession;
      break;
    }
  }

  return foundSession;
}

function addPlayerToRandomSession( player ) {
  // Get Random Session ID
  var session = fetchRandomSession();

  if ( session != false ) {
    // Add Player to Session
    addPlayerToSpecificSession( player, session );

  } else {
    // No sessions found
    sendMessageToPlayer( "noSessions", null, player );
  }
}

function removePlayerFromAnySession( player ) {
  var session = serverData[ 'players' ][ player ][ 'session' ];

  if ( session != null ) {
    // Remove player from session and session from player
    serverData[ "players" ][ player ][ "session" ] = null;
    delete serverData[ 'sessions' ][ session ][ 'players' ][ player ];

    // Approve player leaving
    sendMessageToPlayer( "youLeft", null, player );

    // Inform session that player left
    sendMessageToSession( "playerLeft", { "player": player, "info":serverData[ 'sessions' ][ session ] }, session );
     
    // Print
    console.log( `Removed player ${player} from session ${session}` );

    // Send the updated session information to all players in the session
    updateSession( session );

    // Send state updates to session
    updateSessionState( session );
  }
}

function removePlayerFromSpecificSession( player, session ) {
  var players = serverData[ 'sessions' ][ session ][ 'players' ];
  
  if ( player in players ) {
    // Remove player from session and session from player
    serverData[ "players" ][ player ][ "session" ] = null;
    delete serverData[ 'sessions' ][ session ][ 'players' ][ player ];

    // Approve player leaving
    sendMessageToPlayer( "youLeft", null, player );

    // Inform session that player left
    sendMessageToSession( "playerLeft", { "player": player, "info":serverData[ 'sessions' ][ session ] }, session );
    
    // Print
    console.log( `Removed player ${player} from session ${session}` );
    
    // Send the updated session information to all players in the session
    updateSession( session );

    // Send state updates to session
    updateSessionState( session );
  }
}

function endSession( session ) {
  Object.keys( serverData[ "sessions" ][ session ][ "players" ] ).forEach( ( player ) => {
    if ( player != serverData[ "sessions" ][ session ][ "host" ] ) {
      sendMessageToPlayer( "sessionTerminated", null, player );

      console.log( `SENT MESSAGE TO PLAYER: ${player}` );
    }

    removePlayerFromAnySession( player );
  } );

  delete serverData[ "sessions" ][ session ];
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

function getNumberOfPlayersInSession( session ) {
  var numberOfPlayers = Object.keys( serverData[ 'sessions' ][ session ][ "players" ] ).length;

  return numberOfPlayers;
}

function updateSessionState( session ) {
  var state = serverData[ "sessions" ][ session ][ "state" ];
  var limit = serverData[ "sessions" ][ session ][ "limit" ];
  var remainingTime = serverData[ "sessions" ][ session ][ "remainingTime" ]
  var numberOfPlayers = getNumberOfPlayersInSession( session );

  var newState = state;

  // If no players in session, end session
  if ( numberOfPlayers == 0 ) {
    endSession( session );
  }

  // Check time
  if ( remainingTime <= 0 ) {
    newState = "waiting";
  }

  // If all players in session, put session in playing state
  // Check ready state for players
  if ( ( state == "waiting" ) && ( numberOfPlayers == limit ) ) {
    newState = "playing";
  }

  if ( newState != state ) {
    serverData[ "sessions" ][ session ][ "state" ] = newState;
    sendMessageToSession( "stateChanged", { "state": newState }, session );

    // Print
    console.log(`Old State: ${state}`);
    console.log(`New State: ${newState}`);
  }
}

function updateTime() {
  Object.keys( serverData[ "sessions" ] ).forEach( ( session ) => {
    if ( serverData[ "sessions" ][ session ][ "state" ] == "playing" ) {
      serverData[ "sessions" ][ session ][ "remainingTime" ] -= 1000;

      updateSessionState( session )

      sendMessageToSession( "timeUpdated", { "remainingTime": serverData[ "sessions" ][ session ][ "remainingTime" ] }, session );
    }
  } );
}