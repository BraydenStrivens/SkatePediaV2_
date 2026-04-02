import * as functions from "firebase-functions";

import { cleanupOrphanedUsernameReservations } from "./functions/cleanup/deleteOrphanedUsernames";
import { sendCommentNotification } from "./functions/notifications/sendCommentNotification";
import { deleteBaseComment } from "./functions/posts/comments/deleteBaseComment";
import { deleteReplyComment } from "./functions/posts/comments/deleteReplyComment";
import { onCommentWritten } from "./functions/posts/comments/onCommentWritten";
import { uploadBaseComment } from "./functions/posts/comments/uploadBaseComment";
import { uploadReplyComment } from "./functions/posts/comments/uploadReplyComment";
import { deletePost } from "./functions/posts/deletePost";
import { onPostUploaded } from "./functions/posts/onPostUpload";
import { uploadPost } from "./functions/posts/uploadPost";
import { deleteTrickItem } from "./functions/trick_items/deleteTrickItem";
import { onTrickItemWritten } from "./functions/trick_items/onTrickItemWritten";
import { finalizeTrickItemUpload } from "./functions/trick_items/uploadTrickItem";
import { deleteCustomTrick } from "./functions/trick_list/deleteCustomTrick";
import { onTrickWritten } from "./functions/trick_list/onTrickWritten";
import { uploadTrick } from "./functions/trick_list/uploadTrick";
import { createInitialUserData } from "./functions/user/createUser";
import { onUserPendingDeletion } from "./functions/user/onUserPendingDelete";
import { propagateUserUpdates } from "./functions/user/propagateUserUpdates";

functions.setGlobalOptions({
    maxInstances: 10,
    timeoutSeconds: 60,
});

// User
export { createInitialUserData };
export { onUserPendingDeletion };
export { propagateUserUpdates };

// Trick List
export { uploadTrick };
export { onTrickWritten };
export { deleteCustomTrick };

// Trick Items
export { finalizeTrickItemUpload };
export { onTrickItemWritten };
export { deleteTrickItem };

// Posts
export { uploadPost };
export { deletePost };
export { onPostUploaded };

// Comments
export { uploadBaseComment };
export { deleteBaseComment };
export { uploadReplyComment };
export { deleteReplyComment };
export { onCommentWritten };

// Notifications
export { sendCommentNotification };

// Scheduled Cleanup
export { cleanupOrphanedUsernameReservations };
