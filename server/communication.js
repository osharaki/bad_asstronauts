const helpers = require("./helpers.js");
const serverData = require("./data.js").serverData;

const sendMessageToSession = (action, data, session, except = []) => {
    var players = serverData["sessions"][session]["players"];

    // Send message to all players in the session
    Object.keys(players).forEach((player) => {
        if (!helpers.iterableContainsItem(except, player)) {
            sendMessageToPlayer(action, data, player);
        }
    });
};

function sendMessageToPlayer(action, data, player) {
    // Create Message
    const message = compileMessage(action, data);

    // Get WebSocket
    var playerWebSocket = serverData["players"][player]["websocket"];

    // Send
    playerWebSocket.send(message);
}

function compileMessage(action, data) {
    // Compile Message
    var message = { action: action, data: data };
    var encodedMessage = JSON.stringify(message);

    return encodedMessage;
}

module.exports = { sendMessageToSession, sendMessageToPlayer };
