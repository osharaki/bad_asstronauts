const helpers = require("./helpers");
const { serverData, sessions } = require("./data");
const communication = require("./communication");
const { Player, Planet } = require("./data");

class Session {
    constructor(id, hostId, maxPlayers) {
        this.id = id;
        this.hostId = hostId;
        this.players = [];
        this.planets = [new Planet(-1, 1000)];
        this.state = "waiting";
        this.maxPlayers = maxPlayers;
        this.time = 60000;
        this.remainingTime = this.time;

        this.addPlayer(this.hostId);
    }

    addPlayer(playerId) {
        this.players.push(new Player(playerId, 100));
        this.planets.push(new Planet(playerId, 0));
    }

    removePlayer(playerId) {
        this.players.forEach((player) => {
            if (player.id == playerId) {
                // Approve player leaving
                // TODO Re-add communication!
                /* communication.sendMessageToPlayer("youLeft", null, playerId); */

                this.players.splice(this.players.indexOf(player), 1);
            }

            // If no more players in session
            if (this.players.length()) {
                this.endSession();
            } else {
                // Assign new host
                if (playerId == this.host) {
                    this.assignRandomHostToSession(); // TODO Implement this method
                }

                // Inform session that player left
                // TODO Re-add communication!
                /* communication.sendMessageToSession(
                    "playerLeft",
                    { player: playerId, info: this },
                    this.id
                ); */

                // Print
                console.log(
                    `Removed player ${playerId} from session ${this.id}`
                );
            }
        });
    }

    endSession() {
        this.players.forEach((player) => {
            if (player.id != this.hostId) {
                // TODO Re-add communication!
                /* communication.sendMessageToPlayer(
                    "sessionTerminated",
                    null,
                    player.id
                ); */
            }

            this.removePlayer(player.id);
        });

        sessions.splice(sessions.indexOf(this), 1);
    }

    updateSessionState(state) {
        if (!state) {
            if (this.players.length == 0) {
                this.endSession();
                return;
            }

            if (this.state == "creating") {
                this.state = "waiting";
            } else if (this.state == "waiting") {
                // TODO: Check ready state for players
                if (this.players.size() == this.limit) {
                    // newState = "playing";
                    console.log("Session Full!");
                }
            } else if (this.state == "playing") {
                if (this.remainingTime <= 0) {
                    this.state = "waiting";
                }
            }
        } else if (this.state != state) {
            // TODO Re-add communicate
            /* communication.sendMessageToSession(
                "stateChanged",
                { state: state },
                this.id
            ); */

            if (this.state == "waiting" && state == "playing") {
                this.remainingTime = this.time;
            }

            console.log(`Old State: ${this.state}`);
            console.log(`New State: ${state}`);
            this.state = state;
        }
    }

    // TODO Port rest of methods
}

const removePlayerFromSession = (player, session = null) => {
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
            communication.sendMessageToPlayer("youLeft", null, player);

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
                communication.sendMessageToSession(
                    "playerLeft",
                    { player: player, info: serverData["sessions"][session] },
                    session
                );

                // Print
                console.log(`Removed player ${player} from session ${session}`);
            }
        }
    }
};

const endSession = (session) => {
    if (sessionExists(session)) {
        Object.keys(serverData["sessions"][session]["players"]).forEach(
            (player) => {
                if (player != serverData["sessions"][session]["host"]) {
                    communication.sendMessageToPlayer(
                        "sessionTerminated",
                        null,
                        player
                    );
                }

                removePlayerFromSession(player);
            }
        );

        delete serverData["sessions"][session];
    }
};

const updateSession = (session) => {
    // Send the updated session information to all players in the session
    communication.sendMessageToSession(
        "update",
        { info: serverData["sessions"][session] },
        session
    );
};

const getNumberOfPlayersInSession = (session) => {
    var numberOfPlayers = Object.keys(
        serverData["sessions"][session]["players"]
    ).length;

    return numberOfPlayers;
};

const updateSessionState = (session, setState = null) => {
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
        newState = setState;
    }

    // Communicate
    if (newState != state) {
        serverData["sessions"][session]["state"] = newState;
        communication.sendMessageToSession(
            "stateChanged",
            { state: newState },
            session
        );

        if (state == "waiting" && newState == "playing") {
            resetSession(session);
        }

        // Print
        console.log(`Old State: ${state}`);
        console.log(`New State: ${newState}`);
    }
};

const resetSession = (session) => {
    // Reset Time
    resetSessionTime(session);
};

const resetSessionTime = (session) => {
    serverData["sessions"][session]["remainingTime"] =
        serverData["sessions"][session]["time"];
};

const sessionEmpty = (session) => {
    if (getNumberOfPlayersInSession(session) == 0) {
        return true;
    }

    return false;
};

const addPlayerToRandomSession = (player) => {
    // Get Random Session ID
    var session = fetchRandomSession();

    if (session != false) {
        // Add Player to Session
        addPlayerToSpecificSession(player, session);
    } else {
        // No sessions found
        communication.sendMessageToPlayer("noSessions", null, player);
    }
};

const fetchRandomSession = () => {
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
        sessions = helpers.removeItemFromIterable(randomSession, sessions);

        // Join session if waiting
        if (serverData["sessions"][randomSession]["state"] == "waiting") {
            foundSession = randomSession;
            break;
        }
    }

    return foundSession;
};

const fetchRandomPlayerFromSession = (session) => {
    var players = Object.keys(serverData["sessions"][session]["players"]);

    // Pick Random Player
    var randomPlayerIndex = Math.floor(Math.random() * players.length);
    var randomPlayer = players[randomPlayerIndex];

    return randomPlayer;
};

const addPlayerToSpecificSession = (player, session) => {
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
        helpers.assignPlayerColor(player);

        // Inform session that player joined
        communication.sendMessageToSession(
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
};

const getSessionData = (session) => {
    var data = serverData["sessions"][session];

    return data;
};

const getPlayerSession = (player) => {
    var session = serverData["players"][player]["session"];

    return session;
};

const assignRandomHostToSession = (session) => {
    if (sessionExists(session)) {
        var randomHost = fetchRandomPlayerFromSession(session);

        assignHostToSession(randomHost, session);
    }
};

const startSession = (session) => {
    updateSessionState(session, "playing");
    sessions[session].updateSessionState("playing");
};

const getSessionColors = (session) => {
    var colors = [];

    Object.keys(serverData["sessions"][session]["players"]).forEach(
        (player) => {
            var color =
                serverData["sessions"][session]["players"][player]["color"];
            colors.push(color);
        }
    );

    return colors;
};

const assignHostToSession = (host, session) => {
    serverData["sessions"][session]["host"] = host;

    // Send the updated session information to all players in the session
    updateSession(session);
};

const sessionExists = (session) => {
    if (
        helpers.iterableContainsItem(
            Object.keys(serverData["sessions"]),
            session
        )
    ) {
        return true;
    }

    return false;
};

const createSession = (data, sessionId) => {
    // FIXME remove all the object stuff and keep just the class operations
    var host = data["host"];

    serverData["sessions"][sessionId] = data;
    serverData["sessions"][sessionId]["id"] = sessionId;

    addPlayerToSpecificSession(host, sessionId);

    console.log(`Created Session: ${sessionId}`);
};

module.exports = {
    addPlayerToSpecificSession,
    addPlayerToRandomSession,
    removePlayerFromSession,
    updateSession,
    updateSessionState,
    createSession,
    startSession,
    getSessionColors,
    getPlayerSession,
    Session,
};
