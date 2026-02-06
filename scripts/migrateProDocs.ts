const admin = require("firebase-admin");
const { Firestore } = require("@google-cloud/firestore");

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  storageBucket: "gs://skatepediav2-c98d9.firebasestorage.app",
});

const dbProd = admin.firestore();
const dbLocal = new Firestore({
  host: "127.0.0.1:8080",
  ssl: false,
});

async function copyCollection(collectionName) {
  const snapshot = await dbProd.collection(collectionName).get();
  console.log("DOCUMENTS FOUND: ", snapshot.size);

  for (const doc of snapshot.docs) {
    let data = doc.data();
    if (data) {
      await dbLocal.collection(collectionName).doc(data.id).set(data);
      console.log(
        `COPIED DOC: ${data.pro_data.pro_name}, ${data.trick_data.trick_name}`
      );
    }
  }
}

copyCollection("pro_videos").catch(console.error);
