const { sessions, players } = require("./data.js");

const sendMessageToSession = (action, data, session, except = []) => {
    if (sessions[session] != null) {
        const players = sessions[session].players;

        // Send message to all players in the session
        players.forEach((player) => {
            if (except.includes(player.id)) return;
            sendMessageToPlayer(action, data, player.id);
        });
    }
};

function sendMessageToPlayer(action, data, playerId) {
    // Create Message
    const message = compileMessage(action, data);

    // Get WebSocket
    let playerWebSocket;
    if (players[playerId]) playerWebSocket = players[playerId].ws;

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
