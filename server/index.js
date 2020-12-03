const WebSocket = require("ws");

const wss = new WebSocket.Server({ port: 3000 });

wss.addListener("listening", () => {
    console.log("WebSocket server running...");
});

var serverData = {
    players: {},
    sessions: {},
    assets: {},
};

setInterval(updateTime, 1000);

wss.on("connection", (ws) => {
    // Add player to server
    connectPlayer(ws, wss);

    ws.on("message", (rawMessage) => {
        // Get Player info
        var player = ws["id"];
        var session = serverData["players"][player]["session"];

        // Extract data from message
        var message = JSON.parse(rawMessage);
        var action = message["action"];
        var data = message["data"];

        if (action == "join") {
            var session = data["session"];

            if (session in serverData["sessions"]) {
                addPlayerToSpecificSession(player, session);
            } else {
                sendMessageToPlayer("wrongSession", null, player);
            }
        } else if (action == "update") {
            serverData["sessions"][session] = data;
            updateSession(session);
        } else if (action == "leave") {
            removePlayerFromSession(player);
        } else if (action == "updateSpaceship") {
            serverData["sessions"][session]["players"][player][
                "spaceship"
            ] = data;
            sendMessageToSession(
                "spaceshipUpdated",
                {
                    player: player,
                    info: {
                        resources: data["resources"],
                        position: data["position"],
                        angle: data["angle"],
                    },
                },
                session,
                (except = [player])
            );
        } else if (action == "updatePlanet") {
            // TODO this never gets executed, client never sends such an action
            var player = data["player"];
            var info = data["info"];

            serverData["sessions"][session]["players"][player]["planet"] = info;
            console.log(`${player} RESOURCES: ${info["resources"]}`);
            sendMessageToSession(
                "planetUpdated",
                { player: player, info: info },
                session
            );
        } else if (action == "create") {
            createSession(data);
        } else if (action == "joinRandom") {
            addPlayerToRandomSession(player);
        } else if (action == "start") {
            startSession(data["session"]);
        }
    });

    ws.on("close", (reason) => {
        // TODO doesn't detect broken connections. See https://www.npmjs.com/package/ws#how-to-detect-and-close-broken-connections

        // Get player info
        var player = ws["id"];

        // Remove player from session
        removePlayerFromSession(player);

        // Remove player from server
        disconnectPlayer(player);
    });
});

function removeItemFromIterable(item, iterable) {
    for (var i = 0; i < iterable.length; i++) {
        if (iterable[i] == item) {
            iterable.splice(i, 1);

            break;
        }
    }

    return iterable;
}

function generateID(length = 10) {
    var id = "";
    var characters =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    var charactersLength = characters.length;

    for (var i = 0; i < length; i++) {
        id += characters.charAt(Math.floor(Math.random() * charactersLength));
    }

    return id;
}

function connectPlayer(websocket, server) {
    // Generate, Store, & Send Client ID
    var clientID = generateID();
    websocket["id"] = clientID;
    serverData["players"][clientID] = {
        session: null,
        websocket: websocket,
    };

    sendMessageToPlayer("connect", { id: clientID }, clientID);

    // Print
    console.log(`Connected Client: ${clientID}`);
}

function disconnectPlayer(player) {
    // Remove player from server
    delete serverData["players"][player];

    // Print
    console.log(`Disconnected Client: ${player}`);
}

function createSession(data) {
    var host = data["host"];
    var session = generateID(4);

    serverData["sessions"][session] = data;
    serverData["sessions"][session]["id"] = session;

    addPlayerToSpecificSession(host, session);

    console.log(`Created Session: ${session}`);
}

function assignHostToSession(host, session) {
    serverData["sessions"][session]["host"] = host;

    // Send the updated session information to all players in the session
    updateSession(session);
}

function sessionExists(session) {
    if (iterableContainsItem(Object.keys(serverData["sessions"]), session)) {
        return true;
    }

    return false;
}

function playerInSession(player, session) {
    if (sessionExists(session)) {
        if (
            iterableContainsItem(
                Object.keys(serverData["sessions"][session]["players"]),
                player
            )
        ) {
            return true;
        }
    }

    return false;
}

function assignRandomHostToSession(session) {
    if (sessionExists(session)) {
        var randomHost = fetchRandomPlayerFromSession(session);

        assignHostToSession(randomHost, session);
    }
}

function startSession(session) {
    updateSessionState(session, (setState = "playing"));
}

function getSessionColors(session) {
    var colors = [];

    Object.keys(serverData["sessions"][session]["players"]).forEach(
        (player) => {
            var color =
                serverData["sessions"][session]["players"][player]["color"];
            colors.push(color);
        }
    );

    return colors;
}

function getPlayerSession(player) {
    var session = serverData["players"][player]["session"];

    return session;
}

function getSessionPlayers(session) {
    var players = Object.keys(serverData["sessions"][session]["players"]);

    return players;
}

function getSessionData(session) {
    var data = serverData["sessions"][session];

    return data;
}

function pickRandomFromIterable(iterable) {
    var randomIndex = Math.floor(Math.random() * iterable.length);
    var randomItem = iterable[randomIndex];

    return randomItem;
}

function assignPlayerColor(player) {
    var availableColors = [];
    var session = getPlayerSession(player);
    var takenColors = getSessionColors(session);
    // var colors = [ "red", "green", "blue", "orange", "yellow", "purple", "gold", "silver", "pink" ];
    var colors = [
        "0xFFDF2828",
        "0xFF28DF68",
        "0xFF477EAE",
        "0xFFFF9100",
        "0xFFFFD23F",
        "0xFFaa00ff",
        "0xFFFFC30E",
        "0xFFF3FCF0",
        "0xFFEE4266",
    ];

    colors.forEach((color) => {
        if (!iterableContainsItem(takenColors, color)) {
            availableColors.push(color);
        }
    });

    var randomColor = pickRandomFromIterable(availableColors);

    serverData["sessions"][session]["players"][player]["color"] = randomColor;

    // Print
    console.log(`Assigned Color: ${randomColor} to Player: ${player}`);
}

function addPlayerToSpecificSession(player, session) {
    // If player not in session and session not playing
    if (
        serverData["players"][player]["session"] != session &&
        serverData["sessions"][session]["state"] != "playing"
    ) {
        // Initial Data to assign player
        var initData = {
            ready: false,
            color: null,
            spaceship: {
                position: [50, 50],
                angle: 0,
                resources: 0,
            },
            planet: {
                position: [50, 50],
                resources: 0,
            },
        };

        // Add session in player and player in session
        serverData["players"][player]["session"] = session;
        serverData["sessions"][session]["players"][player] = initData;

        // Assign Color
        assignPlayerColor(player);

        // Inform session that player joined
        sendMessageToSession(
            "playerJoined",
            { player: player, info: getSessionData(session) },
            session
        );

        // Print
        console.log(`Added player ${player} to session ${session}`);

        // Send latest information to session
        updateSession(session);

        // Send state updates to session
        updateSessionState(session);
    }
}

function fetchRandomPlayerFromSession(session) {
    var players = Object.keys(serverData["sessions"][session]["players"]);

    // Pick Random Player
    var randomPlayerIndex = Math.floor(Math.random() * players.length);
    var randomPlayer = players[randomPlayerIndex];

    return randomPlayer;
}

function fetchRandomSession() {
    var sessions = Object.keys(serverData["sessions"]);
    var sessionCount = sessions.length;
    var foundSession = false;
    var count = 0;

    while (count != sessionCount) {
        // Add Count
        count += 1;

        // Pick Random Session
        var randomSessionIndex = Math.floor(Math.random() * sessions.length);
        var randomSession = sessions[randomSessionIndex];

        // Remove Session from Sessions, so next iteration we don't pick it again
        sessions = removeItemFromIterable(randomSession, sessions);

        // Join session if waiting
        if (serverData["sessions"][randomSession]["state"] == "waiting") {
            foundSession = randomSession;
            break;
        }
    }

    return foundSession;
}

function addPlayerToRandomSession(player) {
    // Get Random Session ID
    var session = fetchRandomSession();

    if (session != false) {
        // Add Player to Session
        addPlayerToSpecificSession(player, session);
    } else {
        // No sessions found
        sendMessageToPlayer("noSessions", null, player);
    }
}

function sessionEmpty(session) {
    if (getNumberOfPlayersInSession(session) == 0) {
        return true;
    }

    return false;
}

function removePlayerFromSession(player, session = null) {
    // Get player's session
    if (session == null) {
        session = serverData["players"][player]["session"];
    }

    if (session != null) {
        var host = serverData["sessions"][session]["host"];
        var players = serverData["sessions"][session]["players"];

        if (player in players) {
            // Remove player from session and session from player
            serverData["players"][player]["session"] = null;
            delete serverData["sessions"][session]["players"][player];

            // Approve player leaving
            sendMessageToPlayer("youLeft", null, player);

            // If no more players in session
            if (sessionEmpty(session)) {
                endSession(session);

                // If players remaining in session
            } else {
                // Assign new host
                if (player == host) {
                    assignRandomHostToSession(session);
                }

                // Inform session that player left
                sendMessageToSession(
                    "playerLeft",
                    { player: player, info: serverData["sessions"][session] },
                    session
                );

                // Print
                console.log(`Removed player ${player} from session ${session}`);
            }
        }
    }
}

function endSession(session) {
    if (sessionExists(session)) {
        Object.keys(serverData["sessions"][session]["players"]).forEach(
            (player) => {
                if (player != serverData["sessions"][session]["host"]) {
                    sendMessageToPlayer("sessionTerminated", null, player);
                }

                removePlayerFromSession(player);
            }
        );

        delete serverData["sessions"][session];
    }
}

function sendMessageToPlayer(action, data, player) {
    // Create Message
    message = compileMessage(action, data);

    // Get WebSocket
    var playerWebSocket = serverData["players"][player]["websocket"];

    // Send
    playerWebSocket.send(message);
}

function sendMessageToSession(action, data, session, except = []) {
    var players = serverData["sessions"][session]["players"];

    // Send message to all players in the session
    Object.keys(players).forEach((player) => {
        if (!iterableContainsItem(except, player)) {
            sendMessageToPlayer(action, data, player);
        }
    });
}

function compileMessage(action, data) {
    // Compile Message
    var message = { action: action, data: data };
    var encodedMessage = JSON.stringify(message);

    return encodedMessage;
}

function updateSession(session) {
    // Send the updated session information to all players in the session
    sendMessageToSession(
        "update",
        { info: serverData["sessions"][session] },
        session
    );
}

function getNumberOfPlayersInSession(session) {
    var numberOfPlayers = Object.keys(
        serverData["sessions"][session]["players"]
    ).length;

    return numberOfPlayers;
}

function updateSessionState(session, setState = null) {
    var state = serverData["sessions"][session]["state"];
    var limit = serverData["sessions"][session]["limit"];
    var numberOfPlayers = getNumberOfPlayersInSession(session);
    var remainingTime = serverData["sessions"][session]["remainingTime"];

    if (setState == null) {
        var newState = state;

        if (numberOfPlayers == 0) {
            endSession(session);
            return;
        }

        if (state == "creating") {
            newState = "waiting";
        } else if (state == "waiting") {
            // TODO: Check ready state for players
            if (numberOfPlayers == limit) {
                // newState = "playing";
                console.log("Session Full!");
            }
        } else if (state == "playing") {
            if (remainingTime <= 0) {
                newState = "waiting";
            }
        }
    } else {
        var newState = setState;
    }

    // Communicate
    if (newState != state) {
        serverData["sessions"][session]["state"] = newState;
        sendMessageToSession("stateChanged", { state: newState }, session);

        if (state == "waiting" && newState == "playing") {
            resetSession(session);
        }

        // Print
        console.log(`Old State: ${state}`);
        console.log(`New State: ${newState}`);
    }
}

function resetSession(session) {
    // Reset Time
    resetSessionTime(session);
}

function resetSessionTime(session) {
    serverData["sessions"][session]["remainingTime"] =
        serverData["sessions"][session]["time"];
}

function updateTime() {
    Object.keys(serverData["sessions"]).forEach((session) => {
        if (serverData["sessions"][session]["state"] == "playing") {
            serverData["sessions"][session]["remainingTime"] -= 1000;

            sendMessageToSession(
                "timeUpdated",
                {
                    remainingTime:
                        serverData["sessions"][session]["remainingTime"],
                },
                session
            );

            updateSessionState(session);

            // Update spectating players' respawn timers
            Object.keys(serverData["sessions"][session]["players"]).forEach(
                (player) => {
                    let spaceship =
                        serverData["sessions"][session]["players"][player][
                            "spaceship"
                        ];

                    // Check to see which players are spectating (i.e. crashed)
                    if (spaceship["respawnTime"] != 0) {
                        if (spaceship["respawnTime"] > 0)
                            spaceship["respawnTime"] -= 1;
                        console.log(
                            `Sending respawn time ${spaceship[
                                "respawnTime"
                            ].toString()} to player ${player}`
                        );
                        sendMessageToPlayer(
                            "respawnTimerUpdated",
                            { respawnTime: spaceship["respawnTime"] },
                            player
                        );
                    }
                }
            );
        }
    });
}

function iterableContainsItem(iterable, item) {
    for (var i = 0; i < iterable.length; i++) {
        if (iterable[i] == item) {
            return true;
        }
    }

    return false;
}
