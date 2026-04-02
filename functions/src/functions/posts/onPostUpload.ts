import { logger } from "firebase-functions/v2";
import { onDocumentCreated } from "firebase-functions/v2/firestore";

import { bucket } from "../../firebase";
import type { Post } from "../../utils/interfaces";

/*
Updates a trick item video file's cache control in storage when a post is 
uploaded for a trick item. 

    1. Validate post data
    2. Update cache control
*/
export const onPostUploaded = onDocumentCreated(
    {
        document: "posts/{postId}",
    },
    async (event) => {
        const postId = event.params;

        // 1. Validate post data
        const snapshot = event.data;
        if (!snapshot) {
            logger.warn("On post upload snapshot not found.");
            return;
        }

        const newPost = snapshot.data() as Post;
        if (!newPost.video_data.storage_path) {
            logger.warn(
                "On post upload video_data storage_path undefined.",
            );
            return;
        }

        // 2. Update cache control
        const trickItemVideoFile = bucket.file(
            newPost.video_data.storage_path,
        );

        try {
            await trickItemVideoFile.setMetadata({
                cacheControl: "public, max-age=604800, immutable",
            });
            logger.info(
                "Successfully updated trick item cache settings: ",
                { postId },
            );
        } catch (err: any) {
            logger.error(
                "On post upload storage file cache options failed to be updated.",
                {
                    err,
                },
            );
        }
    },
);
