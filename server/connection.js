const helpers = require("./helpers.js");
const serverData = require("./data.js").serverData;
const communication = require("./communication");

exports.connectPlayer = (websocket, server) => {
    // Generate, Store, & Send Client ID
    var clientID = helpers.generateID();
    websocket["id"] = clientID;
    serverData["players"][clientID] = {
        session: null,
        websocket: websocket,
    };

    communication.sendMessageToPlayer("connect", { id: clientID }, clientID);

    // Print
    console.log(`Connected Client: ${clientID}`);
};

exports.disconnectPlayer = (player) => {
    // Remove player from server
    delete serverData["players"][player];

    // Print
    console.log(`Disconnected Client: ${player}`);
};
