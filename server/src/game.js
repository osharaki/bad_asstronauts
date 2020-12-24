const { sessions } = require("./data");
const communication = require("./communication");

const updateGame = () => {
    // Resource replenishment
    // Resources only start being replenished if the ship hasn't crashed and if
    // they drop below critical levels. Otherwise home planets would have an
    // endless supply of resources, draining the ship as soon as it replenishes
    // its resources and the ship will be stuck. On the planet side of things,
    // the fact that home planets only drain when their ship's resources exceed
    // this critical threshold also ensures that a ship's resources below the
    // threshold act solely as an emergency backup to allow the ship to escape
    // orbit.
    Object.values(sessions).forEach((session) => {
        if (session.state == "playing") {
            session.spaceships.forEach((spaceship, i) => {
                if (
                    spaceship.resources < spaceship.resourceCriticalThreshold &&
                    spaceship.respawnTime == 0
                ) {
                    spaceship.resources += Math.min([
                        spaceship.resourceReplenishRate,
                        spaceship.resourceCriticalThreshold -
                            spaceship.resources,
                    ]);
                }

                // Resource consumption
                // We normalize currentSpeed by dividing it by its maximum
                // possible value
                if (spaceship.thrust) {
                    if (!spaceship.inOrbit) {
                        spaceship.resources -= Math.min(
                            spaceship.resources,
                            spaceship.currentSpeed / 159 / 10
                        );
                    }
                }

                // TODO Perform home planet resource transfer operations
                // ...session.planets[i+1]...
            });
            // TODO Perform central planet resource transfer operations
            // ...session.planets[0]...

            // TODO Inform clients of updates
            communication.sendMessageToSession(
                "gameUpdated",
                session.serializeDynamicData(),
                session.id
            );
        }
    });
};

const updateTime = () => {
    Object.values(sessions).forEach((session) => {
        if (session.state == "playing") {
            session.remainingTime -= 1000;

            communication.sendMessageToSession(
                "timeUpdated",
                {
                    remainingTime: session.remainingTime,
                },
                session.id
            );

            session.updateSessionState();

            // Update spectating players' respawn timers
            session.spaceships.forEach((spaceship) => {
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

module.exports = {
    updateGame,
    updateTime,
};
