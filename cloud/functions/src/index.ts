import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
export const helloWorld = functions.https.onRequest((request, response) => {
    functions.logger.info("Hello logs!", { structuredData: true });
    response.send("Hello from Firebase!");
});

// Take the text parameter passed to this HTTP endpoint and insert it into 
// Cloud Firestore under the path /messages/:documentId/original
exports.addMessage = functions.https.onRequest(async (req, res) => {
    // Grab the text parameter.
    const original = req.query.text;
    console.log(original)
    // Push the new message into Cloud Firestore using the Firebase Admin SDK.
    const writeResult = await admin.firestore().collection('messages').add({ original: original });
    // Send back a message that we've succesfully written the message
    res.json({ result: `Message with ID: ${writeResult.id} added.` });
});

exports.startGame = functions.https.onCall(async (data) => {
    start(data['sessionId']);
})

exports.endGame = functions.https.onCall(async (data) => {
    end(data['sessionId'], data['culprit']);
})

const start = async (sessionId: string) => {
    let sec = 30;
    setInterval(async () => {
        sec--;
        admin.firestore().collection('sessions').doc(sessionId).update({ time: sec });
        if (sec == 0) {
            end(sessionId, null!);
        }
    }, 1000);
    const posX = Math.random() * 100;
    const posY = Math.random() * 100;
    await admin.firestore().collection('sessions').doc(sessionId).update({ started: true, 'boxPosition': { posX: Math.floor(posX), posY: Math.floor(posY), } });
    console.log('Started game successfully');
}

const end = async (sessionId: string, culprit: string) => {

    // check winner
    const players = await admin.firestore().collection('sessions').doc(sessionId).collection('players').get();
    const p1 = players.docs[0];
    const p2 = players.docs[1];
    p1.data
    let winnerId;
    if (!culprit) {
        // time ran out
        if (p1.data()['score'] > p2.data()['score'])
            winnerId = p1
        else
            winnerId = p2
    }
    else if (culprit == p1.id)
        winnerId = p2.id;
    else
        winnerId = p1.id;

    await admin.firestore().collection('sessions').doc(sessionId).update({ time: 30, started: false, boxPosition: { posX: 50, posY: 50 }, winner: winnerId });
    console.log('Ended game successfully');
}



exports.updateBoxPosition = functions.https.onCall(async (data) => {
    // const screenHeight = data.screenHeight;
    // const screenWidth = data.screenWidth;
    const size = 10; //as percentage of height

    const posX = Math.random() * 100;
    const posY = Math.random() * 100;
    console.log(data['sessionId']);
    await admin.firestore().collection('sessions').doc(data['sessionId']).update({ 'boxPosition': { posX: Math.floor(posX), posY: Math.floor(posY), } });
    console.log('Position updated successfully');
});

exports.initializeSession = functions.https.onCall(async (data) => {
    await admin.firestore().collection('sessions').doc(data['sessionId']).set({ started: false, boxPosition: { posX: 50, posY: 50 }, time: 30, ready: false, startCountdown: 5 });
    console.log('Initialized session successfully');
})

exports.incrementScore = functions.https.onCall(async (data) => {
    await admin.firestore().collection('sessions').doc(data['sessionId']).collection('players').doc(data['playerId']).get().then(async (doc) => {
        if (doc.exists) {
            const player = await admin.firestore().collection('sessions').doc(data['sessionId']).collection('players').doc(data['playerId']);
            if (doc.data()) {
                player.update({ score: doc.data()!['score'] + 1 });
            }
            console.log('Incremented score successfully');
        }

    });
})

exports.getUser = functions.https.onRequest(async (req, res) => {
    admin.auth().getUser(req.query.uid as string).then((userRecord) => {
        res.json(userRecord);
    }).catch(() => console.log('Error'));
});

exports.lock
exports.onPlayerJoin = functions.firestore.document('sessions/{sessionId}/{players}/{playerId}').onCreate((snapshot, context) => {
    const playerId = context.params.playerId;
    const sessionId = context.params.sessionId;
    console.log(`Player ${playerId} joined session ${sessionId}`);
    console.log(snapshot.data());
    const player = snapshot.ref;
    const players = player.parent;
    console.log('Checking session status...');
    return players.listDocuments().then((resolve) => {
        if (resolve.length == 2) {
            console.log('Session ready. Starting count down...');
            admin.firestore().collection('sessions').doc(sessionId).update({ ready: true });
            let sec = 5;
            setInterval(async () => {
                sec--;
                admin.firestore().collection('sessions').doc(sessionId).update({ startCountdown: sec });
                if (sec == 0) {
                    // start game

                }
            }, 1000);
        }
        else { console.log('Session not ready'); console.log(resolve); }
        return resolve;
    }).catch((reject) => reject);
});

exports.onPlayerDelete = functions.firestore.document('sessions/{sessionId}/{players}/{playerId}').onDelete((snapshot, context) => {
    const playerId = context.params.playerId;
    const sessionId = context.params.sessionId;
    console.log(`Player ${playerId} left session ${sessionId}`);
    console.log(snapshot.data());
    const player = snapshot.ref;
    const players = player.parent;
    console.log('Checking session status...');
    return players.listDocuments().then(async (resolve) => {
        if (resolve.length == 0) {
            console.log('Session empty. Deleting...');
            players.parent?.delete().then(() => console.log('Session deleted')); // delete empty session
        }
        else {
            console.log('Session not empty');
            console.log(resolve);
            await admin.firestore().collection('sessions').doc(sessionId).update({ ready: false, startCountdown: 5 });
        }
        return resolve;
    }).catch((reject) => reject);
});

export const testAddToEmptyDB = functions.https.onRequest(async (req, res) => {
    await admin.firestore().collection('sessions').doc().set({ a: Math.random() * 100, b: Math.random() * 100 });
    res.json('done');
});