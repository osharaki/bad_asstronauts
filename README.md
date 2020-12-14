# Bad Asstronauts 🛰🌌💥🔫☄🚀👨‍🚀🕹️

Bad Asstronauts is a fast-paced, competitive, multiplayer game where players  in weaponized spaceships scour the cosmos in search of valuable resources to hoard on their home planets. All the while, players must also defend their stash from scavenging opponents. Because in the vast expanse of space, it's all for one or none for all.
May the baddest astronaut win!

## Development
### Server
The game relies on a Node.js WebSocket server located at [/server](/server). Here are the steps to run it locally:

1. In the terminal, navigate to [/server](/server).
2. Run `npm install` to install dependencies.
3. Run `npm run build`. This compiles the .ts files to .js and places the output in */server/build* (untracked)
    - Alternatively, run `npm run build -- --watch` to trigger automatic rebuilds in response to changes.
4. To start the server, run `npm run dev`.
