const serverData = {
    players: {},
    sessions: {},
    assets: {},
};

const sessions = {};

class Planet {
    constructor(id, resources) {
        this.id = id;
        this.resources = resources;
    }
}

class Player {
    constructor(id, color, resources) {
        this.id = id;
        this.color = color;
        this.resources = resources;
    }
}

module.exports = {
    Player,
    Planet,
    serverData,
    sessions,
};
