import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

exports.updateBoxPosition = functions.https.onCall(async () => {
    const posX = Math.random() * 100;
    const posY = Math.random() * 100;
    return admin.firestore().collection('game').doc('position').set({ posX: Math.floor(posX), posY: Math.floor(posY) }).then((res) => {
        if (res)
            console.log('Position updated successfully');
        else
            console.log('Something went wrong while updating position');
        return res
    });
});