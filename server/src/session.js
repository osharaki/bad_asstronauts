const helpers = require("./helpers");
const { serverData, sessions, players, Planet, Spaceship } = require("./data");
const communication = require("./communication");

class Session {
    constructor(id, host, maxPlayers) {
        this.id = id;
        this.hostId = host.id;
        this.players = [];
        this.planets = [new Planet(-1, 1000)];
        this.spaceships = [];
        this.state = "waiting";
        this.maxPlayers = maxPlayers;
        this.respawnTime = 5;
        this.time = 5000; // TODO Used to be 60000
        this.remainingTime = this.time;
        this.availableColors = [
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

        // this.addPlayer(host); // TODO Remove this, we're adding players outside now
    }

    addPlayer(player) {
        const playerId = player.id;
        const playerColor = this.availableColors.pop();
        player.color = playerColor;
        player.sessionId = this.id;

        this.players.push(player);
        this.planets.push(new Planet(playerId, 0));
        this.spaceships.push(new Spaceship(playerId));
        players[playerId].sessionId = this.id;

        // Inform session that player joined
        communication.sendMessageToSession(
            "playerJoined",
            { player: playerId, info: this.serializeSession() },
            this.id
        );
    }

    removePlayer(playerId) {
        this.players.forEach((player) => {
            if (player.id == playerId) {
                communication.sendMessageToPlayer("youLeft", null, playerId);

                const i = this.players.indexOf(player);
                this.players.splice(i, 1);
                this.planets.splice(i + 1, 1); // Central planet is always at index 0, so we always shift by 1
                players[player.id].sessionId = null;

                /* console.log(
                    `Removed player ${playerId} from session ${this.id}`
                );
                console.log(players);
                console.log(this); */
            }

            if (this.players.length == 0) {
                this.endSession();
            } else {
                // Assign new host
                if (playerId == this.hostId) {
                    this.assignRandomHostToSession();
                }

                // Inform session that player left
                const payload = this.serializeSession();
                communication.sendMessageToSession(
                    "playerLeft",
                    { player: playerId, info: payload },
                    this.id
                );

                this.availableColors.push(player.color);
            }
        });
    }

    assignRandomHostToSession() {
        const newHost = this.players[
            Math.floor(Math.random() * this.players.length)
        ];
        this.hostId = newHost.id;

        // Send the updated session information to all players in the session
        const payload = this.serializeSession();
        communication.sendMessageToSession(
            "update",
            { info: payload },
            this.id
        );
        console.log(
            `Player ${this.hostId} assigned as session ${this.id} host`
        );
    }

    serializeSession() {
        const payload = {
            id: this.id,
            host: this.hostId,
            limit: this.maxPlayers,
            respawnTime: this.respawnTime,
            state: this.state,
            players: {},
        };
        this.players.forEach((player, i) => {
            payload["players"][player.id] = {
                color: player.color,
                planet: { resources: this.planets[i + 1].resources },
            };
        });
        // TODO Serialize planet information
        return payload;
    }

    endSession() {
        this.players.forEach((player) => {
            if (player.id != this.hostId) {
                // XXX This is never executed since the host doesn't currently
                // have the ability to terminate the session, only to leave it.
                // This means that the only time this method is called is when
                // the last player leaves the session. Since the last player is
                // by default also the host, the if-condition fails.
                communication.sendMessageToPlayer(
                    "sessionTerminated",
                    null,
                    player.id
                );
            }

            this.removePlayer(player.id);
        });
        delete sessions[this.id];
        console.log(`Deleted session was ${this.id}`);
        console.log(sessions);
    }

    updateSessionState(state) {
        let stateChanged = false;
        if (!state) {
            if (this.players.length == 0) {
                this.endSession();
                return;
            }

            if (this.state == "creating") {
                this.state = "waiting";
                stateChanged = true;
            } else if (this.state == "waiting") {
                // TODO: Check ready state for players
                if (this.players.length == this.limit) {
                    // newState = "playing";
                    // console.log("Session Full!");
                }
            } else if (this.state == "playing") {
                if (this.remainingTime <= 0) {
                    this.state = "waiting";
                    stateChanged = true;
                }
            }
        } else if (this.state != state) {
            if (this.state == "waiting" && state == "playing") {
                // reset time
                this.remainingTime = this.time;
            }
            this.state = state;
            stateChanged = true;
        }
        if (stateChanged)
            communication.sendMessageToSession(
                "stateChanged",
                { state: this.state },
                this.id
            );
        console.log(`Old State: ${this.state}`);
        console.log(`New State: ${state}`);
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
            // communication.sendMessageToPlayer("youLeft", null, player);

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
                /* communication.sendMessageToSession(
                    "playerLeft",
                    { player: player, info: serverData["sessions"][session] },
                    session
                );

                // Print
                console.log(`Removed player ${player} from session ${session}`); */
            }
        }
    }
};

const endSession = (session) => {
    if (sessionExists(session)) {
        Object.keys(serverData["sessions"][session]["players"]).forEach(
            (player) => {
                if (player != serverData["sessions"][session]["host"]) {
                    /* communication.sendMessageToPlayer(
                        "sessionTerminated",
                        null,
                        player
                    ); */
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
                // console.log("Session Full!");
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
        /* communication.sendMessageToSession(
            "stateChanged",
            { state: newState },
            session
        ); */

        if (state == "waiting" && newState == "playing") {
            resetSession(session);
        }

        // Print
        /* console.log(`Old State: ${state}`);
        console.log(`New State: ${newState}`); */
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
    let foundSession = false;

    for (const session of Object.values(sessions)) {
        if (
            session.state == "waiting" &&
            session.players.length < session.maxPlayers
        ) {
            session.addPlayer(player);
            foundSession = true;
            break;
        }
    }

    if (!foundSession) {
        // No sessions found
        communication.sendMessageToPlayer("noSessions", null, player);
    }
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
        /* communication.sendMessageToSession(
            "playerJoined",
            { player: player, info: getSessionData(session) },
            session
        ); */

        // Print
        // console.log(`Added player ${player} to session ${session}`);

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
    // updateSessionState(session, "playing"); // TODO Remove this 🔥
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
    // updateSession(session);
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
