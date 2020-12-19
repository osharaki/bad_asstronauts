const serverData = require("./data").serverData;
const communication = require("./communication");
const sessionManager = require("./session");

module.exports = () => {
    if (serverData["sessions"]) {
        Object.keys(serverData["sessions"]).forEach((session) => {
            if (serverData["sessions"][session]["state"] == "playing") {
                serverData["sessions"][session]["remainingTime"] -= 1000;

                communication.sendMessageToSession(
                    "timeUpdated",
                    {
                        remainingTime:
                            serverData["sessions"][session]["remainingTime"],
                    },
                    session
                );

                sessionManager.updateSessionState(session);

                // Update spectating players' respawn timers
                Object.keys(serverData["sessions"][session]["players"]).forEach(
                    (player) => {
                        let spaceship =
                            serverData["sessions"][session]["players"][player][
                                "spaceship"
                            ];

                        // Check to see which players are spectating (i.e. crashed)
                        if (spaceship["respawnTime"] != null) {
                            if (spaceship["respawnTime"] != 0) {
                                if (spaceship["respawnTime"] > 0)
                                    spaceship["respawnTime"] -= 1;
                                console.log(
                                    `Sending respawn time ${spaceship[
                                        "respawnTime"
                                    ].toString()} to player ${player}`
                                );
                                communication.sendMessageToPlayer(
                                    "respawnTimerUpdated",
                                    { respawnTime: spaceship["respawnTime"] },
                                    player
                                );
                            }
                        }
                    }
                );
            }
        });
    }
};
