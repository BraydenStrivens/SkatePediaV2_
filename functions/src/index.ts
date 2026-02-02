import * as functions from "firebase-functions";

import { createInitialUserData } from "./functions/user/createUser";
import { cleanupOrphanedUsernameReservations } from "./functions/user/deleteOrphanedUsernames";

if (process.env.FIRESTORE_EMULATOR_HOST) {
    console.log("Running on emulator:");
} else {
    console.log("Running on production:");
}

functions.setGlobalOptions({
    maxInstances: 10,
    timeoutSeconds: 60,
});

export { createInitialUserData };
export { cleanupOrphanedUsernameReservations };
