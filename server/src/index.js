const WebSocket = require("ws");
const { performance } = require("perf_hooks");

const connection = require("./connection.js");
const sessionManager = require("./session");
const communication = require("./communication");
const { sessions, players } = require("./data.js");
const { updateTime, updateGame } = require("./game.js");
const generateID = require("./helpers").generateID;

const wss = new WebSocket.Server({ port: 3000 });

wss.addListener("listening", () => {
    console.log("WebSocket server running...");
});

/* 
How the time update works
=========================
performance.now() returns the accurate time elapsed in ms since the start of
execution. The intervals in the denominators (e.g. gameClockInterval) determine
how frequently the updates happen. For example, a denominator of 1000 results in
ca. 1 second intervals, 500 in 2, and so on. Keeping track of the time step
(i.e. tick) allows us to track the progression of time by rounding down dt and
checking whether its value has surpassed the last tick.
*/

let dt = 0;
let t0 = 0; // DEV
const clockInterval = 5;
const gameClockInterval = 1000;
let gameClockTick = 0; // Stores the current discrete time step
const gameUpdateInterval = 25; // set to ~16 to mimic Flame update interval
let gameUpdateTick = 0; // Stores the current discrete time step
const debug = 0;
setInterval(() => {
    dt = performance.now();

    if (Math.floor(dt / gameUpdateInterval) != gameUpdateTick) {
        updateGame();
        gameUpdateTick += 1;
    }

    if (Math.floor(dt / gameClockInterval) != gameClockTick) {
        if (debug) {
            // DEV
            console.log(
                `Time since previous update: ${performance.now() - t0}`
            );
            t0 = performance.now();
            console.log(`dt: ${dt}`);
            console.log(`gameClockTick: ${gameClockTick}`);
            console.log(
                `dt/${gameClockInterval}: ${Math.floor(dt / gameClockInterval)}`
            );
        }

        gameClockTick += 1;
        updateTime();
    }
}, clockInterval);

wss.on("connection", (ws) => {
    // Add player to server
    connection.connectPlayer(ws, wss);
    ws.on("message", (rawMessage) => {
        // Get Player info
        let player = ws["id"];

        // Check required since a player trying to create a session will have no
        // sessionId
        // FIXME Instead of always trying to fetch the sessionId on every
        // message, fetch it on demand in the if-branches that need it
        let sessionId = sessions[players[player].sessionId]
            ? sessions[players[player].sessionId].id
            : null;

        // Extract data from message
        const message = JSON.parse(rawMessage);
        const action = message["action"];
        const data = message["data"];

        if (action == "join") {
            sessionId = data["session"];

            if (sessions[sessionId] != null) {
                sessions[sessionId].addPlayer(players[player]);
                sessions[sessionId].updateSessionState();
            } else {
                communication.sendMessageToPlayer("wrongSession", null, player);
            }
        } else if (action == "leave") {
            sessions[data["session"]].removePlayer(player);
        } else if (sessionId && action == "updateSpaceship") {
            for (const spaceship of sessions[sessionId].spaceships) {
                if (spaceship.id == player) {
                    spaceship.position = data["position"];
                    spaceship.resources = data["resources"];
                    spaceship.angle = data["angle"];
                    spaceship.respawnTime = data["respawnTime"];
                    spaceship.resourceReplenishRate =
                        data["resourceReplenishRate"];
                    spaceship.resourceCriticalThreshold =
                        data["resourceCriticalThreshold"];
                    spaceship.currentSpeed = data["currentSpeed"];
                    spaceship.inOrbit = data["inOrbit"];
                    spaceship.thrust = data["thrust"];
                    break;
                }
            }
        } else if (sessionId && action == "updatePlanet") {
            // FIXME this never gets executed, client never sends such an action
            player = data["player"];
            const info = data["info"];

            for (const planet of sessions[sessionId].planets) {
                if (planet.id == player) {
                    planet.resources = info["resources"];
                    planet.position = info["position"];
                    // TODO update remaining attributes
                    break;
                }
            }

            console.log(`${player} RESOURCES: ${info["resources"]}`);
            communication.sendMessageToSession(
                "planetUpdated",
                { player: player, info: info },
                sessionId
            );
        } else if (action == "create") {
            if (players[data["host"]].sessionId == null) {
                const sessionId = generateID(4);
                sessions[sessionId] = new sessionManager.Session(
                    sessionId,
                    players[data["host"]],
                    data["limit"]
                );

                // addPlayer() was moved outside of Session's constructor since
                // we're calling sendMessageToSession(), which uses sessions.
                // Since at that point, sessions[sessionId] would still be null,
                // we defer the call to addPlayer() till after it's populated by
                // calling it here.
                sessions[sessionId].addPlayer(players[data["host"]]);
                console.log(sessionId);
            }
        } else if (action == "joinRandom") {
            sessionManager.addPlayerToRandomSession(player);
        } else if (action == "start") {
            sessionManager.startSession(data["session"]);
        }
    });

    ws.on("close", (reason) => {
        // Get player info
        const playerId = ws["id"];

        // Remove player from session
        if (sessions[players[playerId].sessionId])
            sessions[players[playerId].sessionId].removePlayer(playerId);

        // Remove player from server
        connection.disconnectPlayer(playerId);
    });
});
