const { sessions, players, Planet, Spaceship } = require("./data");
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
        this.time = 60000;
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
        for (const player of this.players) {
            if (player.id == playerId) {
                communication.sendMessageToPlayer("youLeft", null, playerId);

                const i = this.players.indexOf(player);
                this.players.splice(i, 1);
                this.planets.splice(i + 1, 1); // Central planet is always at index 0, so we always shift by 1
                players[player.id].sessionId = null;
                this.availableColors.push(player.color);

                /* console.log(
                    `Removed player ${playerId} from session ${this.id}`
                );
                console.log(players);
                console.log(this); */
                break;
            }
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
        }
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
}

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

const startSession = (session) => {
    sessions[session].updateSessionState("playing");
};

module.exports = {
    addPlayerToRandomSession,
    startSession,
    Session,
};
