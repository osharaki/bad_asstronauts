const helpers = require("./helpers.js");
const { players, Player } = require("./data.js");
const communication = require("./communication");

exports.connectPlayer = (websocket, server) => {
    var clientID = helpers.generateID();
    websocket["id"] = clientID;
    players[clientID] = new Player(clientID, websocket);
    communication.sendMessageToPlayer("connect", { id: clientID }, clientID);

    console.log(`Connected Client: ${clientID}`);
};

exports.disconnectPlayer = (player) => {
    delete players[player];

    console.log(`Disconnected Client: ${player}`);
};
