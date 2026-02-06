import * as functions from "firebase-functions";

import { onTrickWritten } from "./functions/trick_list/onTrickWritten";
import { uploadTrick } from "./functions/trick_list/uploadTrick";
import { createInitialUserData } from "./functions/user/createUser";
import { cleanupOrphanedUsernameReservations } from "./functions/user/deleteOrphanedUsernames";

functions.setGlobalOptions({
    maxInstances: 10,
    timeoutSeconds: 60,
});

export { createInitialUserData };
export { onTrickWritten };
export { uploadTrick };
export { cleanupOrphanedUsernameReservations };
