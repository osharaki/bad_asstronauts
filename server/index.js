const WebSocket = require("ws");

const connection = require("./connection.js");
const sessionManager = require("./session");
const communication = require("./communication");
const serverData = require("./data.js").serverData;
const updateTime = require("./time.js");

const wss = new WebSocket.Server({ port: 3000 });

wss.addListener("listening", () => {
    console.log("WebSocket server running...");
});

setInterval(updateTime, 1000);

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
            sessionManager.createSession(data);
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
