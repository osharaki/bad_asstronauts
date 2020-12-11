const serverData = require("./data.js").serverData;
const sessionManager = require("./session");

exports.assignPlayerColor = (player) => {
    var availableColors = [];
    var session = sessionManager.getPlayerSession(player);
    var takenColors = sessionManager.getSessionColors(session);
    // var colors = [ "red", "green", "blue", "orange", "yellow", "purple", "gold", "silver", "pink" ];
    var colors = [
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

    colors.forEach((color) => {
        if (!this.iterableContainsItem(takenColors, color)) {
            availableColors.push(color);
        }
    });

    var randomColor = this.pickRandomFromIterable(availableColors);

    serverData["sessions"][session]["players"][player]["color"] = randomColor;

    // Print
    console.log(`Assigned Color: ${randomColor} to Player: ${player}`);
};

exports.iterableContainsItem = (iterable, item) => {
    for (var i = 0; i < iterable.length; i++) {
        if (iterable[i] == item) {
            return true;
        }
    }

    return false;
};

exports.pickRandomFromIterable = (iterable) => {
    var randomIndex = Math.floor(Math.random() * iterable.length);
    var randomItem = iterable[randomIndex];

    return randomItem;
};

exports.generateID = (length = 10) => {
    var id = "";
    var characters =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    var charactersLength = characters.length;

    for (var i = 0; i < length; i++) {
        id += characters.charAt(Math.floor(Math.random() * charactersLength));
    }

    return id;
};

exports.removeItemFromIterable = (item, iterable) => {
    for (var i = 0; i < iterable.length; i++) {
        if (iterable[i] == item) {
            iterable.splice(i, 1);

            break;
        }
    }

    return iterable;
};
