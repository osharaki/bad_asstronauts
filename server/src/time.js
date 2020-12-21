const { sessions } = require("./data");
const communication = require("./communication");

module.exports = () => {
    Object.keys(sessions).forEach((session) => {
        if (sessions[session].state == "playing") {
            sessions[session].remainingTime -= 1000;

            communication.sendMessageToSession(
                "timeUpdated",
                {
                    remainingTime: sessions[session].remainingTime,
                },
                session
            );

            sessions[session].updateSessionState();

            // Update spectating players' respawn timers
            sessions[session].spaceships.forEach((spaceship) => {
                // Check to see which players are spectating (i.e. crashed)
                if (spaceship.respawnTime != null) {
                    if (spaceship.respawnTime != 0) {
                        if (spaceship.respawnTime > 0)
                            spaceship.respawnTime -= 1;
                        console.log(
                            `Sending respawn time ${spaceship.respawnTime.toString()} to player ${
                                spaceship.id
                            }`
                        );
                        communication.sendMessageToPlayer(
                            "respawnTimerUpdated",
                            { respawnTime: spaceship.respawnTime },
                            spaceship.id
                        );
                    }
                }
            });
        }
    });
};
