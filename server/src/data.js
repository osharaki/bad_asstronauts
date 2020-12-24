const sessions = {};
const players = {};

class Planet {
    constructor(id, resources) {
        this.id = id;
        this.resources = resources;
        this.position = null;
        this.spaceshipsInOrbit = [];
    }
}

class Spaceship {
    constructor(id) {
        this.id = id;
        this.thrust = false;
        this.respawnTime = 0;
        this.inOrbit = false;
        this.resources = 100;
        this.resourceCriticalThreshold = 6;
        this.resourceReplenishRate = 0.0005;
        this.position = null;
        this.angle = null;
        this.currentSpeed = null;
    }
}

class Player {
    constructor(id, ws) {
        this.id = id;
        this.sessionId = null;
        this.color = null;
        this.ready = false;
        this.ws = ws;
    }
}

module.exports = {
    Player,
    Planet,
    Spaceship,
    sessions,
    players,
};
