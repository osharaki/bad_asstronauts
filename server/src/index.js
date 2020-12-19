const WebSocket = require("ws");
const { performance } = require("perf_hooks");

const connection = require("./connection.js");
const sessionManager = require("./session");
const communication = require("./communication");
const { serverData, sessions } = require("./data.js");
const updateTime = require("./time.js");
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
let tick = 0; // Stores the current discrete time step
let t0 = 0; // DEV
const clockInterval = 5;
const gameClockInterval = 1000;
const debug = 0;
setInterval(() => {
    dt = performance.now();

    if (Math.floor(dt / gameClockInterval) != tick) {
        if (debug) {
            // DEV
            console.log(
                `Time since previous update: ${performance.now() - t0}`
            );
            t0 = performance.now();
            console.log(`dt: ${dt}`);
            console.log(`tick: ${tick}`);
            console.log(
                `dt/${gameClockInterval}: ${Math.floor(dt / gameClockInterval)}`
            );
        }

        tick += 1;
        updateTime();
    }
}, clockInterval);

wss.on("connection", (ws) => {
    // Add player to server
    connection.connectPlayer(ws, wss);
    ws.on("message", (rawMessage) => {
        // Get Player info
        var player = ws["id"];
        var session = serverData["players"][player]["session"];

        // Extract data from message
        var message = JSON.parse(rawMessage);
        var action = message["action"];
        var data = message["data"];

        if (action == "join") {
            session = data["session"];

            if (sessions[session]) {
                sessions[session].addPlayer(player);
                sessions[session].updateSessionState();
            }
            if (session in serverData["sessions"]) {
                sessionManager.addPlayerToSpecificSession(player, session);
            } else {
                communication.sendMessageToPlayer("wrongSession", null, player);
            }
        } else if (action == "update") {
            serverData["sessions"][session] = data;
            sessionManager.updateSession(session);
        } else if (action == "leave") {
            sessionManager.removePlayerFromSession(player);
        } else if (action == "updateSpaceship") {
            if (serverData["sessions"][session] != null) {
                serverData["sessions"][session]["players"][player][
                    "spaceship"
                ] = data;
                communication.sendMessageToSession(
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
                    [player]
                );
            }
        } else if (action == "updatePlanet") {
            // TODO this never gets executed, client never sends such an action
            player = data["player"];
            var info = data["info"];

            serverData["sessions"][session]["players"][player]["planet"] = info;
            console.log(`${player} RESOURCES: ${info["resources"]}`);
            communication.sendMessageToSession(
                "planetUpdated",
                { player: player, info: info },
                session
            );
        } else if (action == "create") {
            const sessionId = generateID(4);
            sessionManager.createSession(data, sessionId); // XXX Remove 🔥
            sessions[sessionId] = new sessionManager.Session(
                sessionId,
                data["host"],
                data["limit"]
            );
        } else if (action == "joinRandom") {
            sessionManager.addPlayerToRandomSession(player);
        } else if (action == "start") {
            sessionManager.startSession(data["session"]);
        }
    });

    ws.on("close", (reason) => {
        // TODO doesn't detect broken connections. See https://www.npmjs.com/package/ws#how-to-detect-and-close-broken-connections

        // Get player info
        var player = ws["id"];

        // Remove player from session
        sessionManager.removePlayerFromSession(player);

        // Remove player from server
        connection.disconnectPlayer(player);
    });
});
