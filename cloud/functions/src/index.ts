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
    return start(data['sessionId']);
})

exports.endGame = functions.https.onCall(async (data) => {
    return end(data['sessionId'], data['culprit']);
})

const start = async (sessionId: string) => {
    let sec = 30;
    admin.firestore().collection('sessions').doc(sessionId).update({ time: sec });
    let endTimer = setInterval(async () => {
        admin.firestore().collection('sessions').doc(sessionId).update({ time: sec });
        if (sec === 0) {
            clearInterval(endTimer);
            end(sessionId, null!);
        }
        sec--;
    }, 1000);
    const posX = Math.random() * 100;
    const posY = Math.random() * 100;
    return admin.firestore().collection('sessions').doc(sessionId).update({ started: true, 'boxPosition': { posX: Math.floor(posX), posY: Math.floor(posY) } }).then((res) => {
        if (res)
            console.log('Started game successfully');
        else
            console.log('Something went wrong while starting game!');
        return res;
    });
}

const end = async (sessionId: string, culprit: string) => {

    // check winner
    const players = await admin.firestore().collection('sessions').doc(sessionId).collection('players').get();
    const p1 = players.docs[0];
    const p2 = players.docs[1];
    p1.data
    let winnerId: string;
    if (!culprit) {
        // time ran out
        if (p1.data()['score'] > p2.data()['score'])
            winnerId = p1.id
        else if (p1.data()['score'] > p2.data()['score'])
            winnerId = p2.id
        else
            winnerId = 'tie';
    }
    else if (culprit === p1.id)
        winnerId = p2.id;
    else
        winnerId = p1.id;

    return admin.firestore().collection('sessions').doc(sessionId).update({ time: 30, started: false, boxPosition: { posX: 50, posY: 50 }, winner: winnerId }).then((res) => {
        if (res)
            console.log('Ended game successfully');
        else
            console.log('Something went wrong while ending game');
        return res
    });
}

exports.updateBoxPosition = functions.https.onCall(async (data) => {
    const posX = Math.random() * 100;
    const posY = Math.random() * 100;
    console.log(data['sessionId']);
    return admin.firestore().collection('sessions').doc(data['sessionId']).update({ 'boxPosition': { posX: Math.floor(posX), posY: Math.floor(posY) } }).then((res) => {
        if (res)
            console.log('Position updated successfully');
        else
            console.log('Something went wrong while updating position');
        return res
    });
});

exports.initializeSession = functions.https.onCall(async (data) => {
    return admin.firestore().collection('sessions').doc(data['sessionId']).set({ started: false, boxPosition: { posX: 50, posY: 50 }, time: 30, ready: false, startCountdown: 5 }).then((res) => {
        if (res)
            console.log('Initialized session successfully');
        else
            console.log('Something went wrong while initializing session');
        return res;
    });

})

exports.incrementScore = functions.https.onCall(async (data) => {
    return admin.firestore().collection('sessions').doc(data['sessionId']).collection('players').doc(data['playerId']).get().then(async (doc) => {
        // The ! is an assurance by us that doc.data() is not null
        doc.ref.update({ score: doc.data()!['score'] + 1 }).then((res) => {
            if (res)
                console.log('Incremented score successfully');
            else
                console.log('Something went wrong while incrementing score');
            return res;
        });
    });
});

exports.getUser = functions.https.onRequest(async (req, res) => {
    admin.auth().getUser(req.query.uid as string).then((userRecord) => {
        res.json(userRecord);
    }).catch(() => console.log('Error'));
});

exports.onPlayerJoin = functions.firestore.document('sessions/{sessionId}/{players}/{playerId}').onCreate(async (snapshot, context) => {
    const playerId = context.params.playerId;
    const sessionId = context.params.sessionId;
    console.log(`Player ${playerId} joined session ${sessionId}`);
    const player = snapshot.ref;
    console.log('Checking session status...');
    const players = await player.parent.listDocuments();
    if (players.length === 2) {
        console.log('Session ready. Starting count down...');
        let sec = 5;
        admin.firestore().collection('sessions').doc(sessionId).update({ startCountdown: sec });
        let startTimer = setInterval(() => {
            admin.firestore().collection('sessions').doc(sessionId).update({ startCountdown: sec });
            if (sec === 0) {
                clearInterval(startTimer)
                // start game
                start(sessionId);
            }
            sec--
        }, 1000);
        admin.firestore().collection('sessions').doc(sessionId).update({ ready: true });
    }
    else {
        console.log('Session not ready. Awaiting second player.');
    }
});

exports.onPlayerDelete = functions.firestore.document('sessions/{sessionId}/{players}/{playerId}').onDelete((snapshot, context) => {
    const playerId = context.params.playerId;
    const sessionId = context.params.sessionId;
    console.log(`Player ${playerId} left session ${sessionId}`);
    const player = snapshot.ref;
    const players = player.parent;
    console.log('Checking session status...');
    return players.listDocuments().then(async (res) => {
        if (res.length === 0) {
            console.log('Session empty. Deleting...');
            return players.parent?.delete(); // delete empty session
        }
        else {
            console.log('Session not empty');
            return admin.firestore().collection('sessions').doc(sessionId).update({ ready: false, startCountdown: 5 });
        }
    }).then((res) => {
        return res;
    }).catch((reject) => reject);
});

export const testAddToEmptyDB = functions.https.onRequest(async (req, res) => {
    await admin.firestore().collection('sessions').doc().set({ a: Math.random() * 100, b: Math.random() * 100 });
    res.json('done');
});