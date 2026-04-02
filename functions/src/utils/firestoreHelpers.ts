import type {
    FirestoreDataConverter,
    QueryDocumentSnapshot,
    Transaction,
} from "firebase-admin/firestore";
import { FieldValue } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/v2/https";

import type { Trick, TrickItem, User, Post, Comment } from "./interfaces";
import { db } from "../firebase";

/*
Contains functions for fetching documents from firestore and converting them using 
custom interfaces to ensure type safety.
    1. User
    2. Trick
    3. Trick Item
    4. Post
    5. Comment
*/

/* 1. USER ======================================================= */
const userConverter: FirestoreDataConverter<User> = {
    toFirestore(user: User) {
        return user;
    },
    fromFirestore(snapshot: QueryDocumentSnapshot): User {
        return snapshot.data() as User;
    },
};

export async function fetchUserById(
    userId: string,
    tx?: Transaction,
): Promise<User | null> {
    const userRef = db
        .collection("users")
        .doc(userId)
        .withConverter(userConverter);

    const snapshot = tx ? await tx.get(userRef) : await userRef.get();

    if (!snapshot.exists) {
        return null;
    }

    return snapshot.data()!;
}

// Validates a user's document exists and is not pending deletion
export async function assertUserActive(uid: string) {
    const userSnap = await db
        .collection("users")
        .doc(uid)
        .withConverter(userConverter)
        .get();

    if (!userSnap.exists) {
        throw new HttpsError(
            "failed-precondition",
            "User document does not exist.",
        );
    }

    const userData = userSnap.data();

    if (userData?.pending_deletion === true) {
        throw new HttpsError(
            "failed-precondition",
            "This account is pending deletion and cannot perform this action.",
        );
    }

    return userData;
}

/* 2. TRICK ======================================================= */

const trickConverter: FirestoreDataConverter<Trick> = {
    toFirestore(trick: Trick) {
        return trick;
    },
    fromFirestore(snapshot: QueryDocumentSnapshot): Trick {
        return snapshot.data() as Trick;
    },
};

export async function fetchTrickById(
    userId: string,
    trickId: string,
    tx?: Transaction,
): Promise<Trick | null> {
    const trickRef = db
        .collection("users")
        .doc(userId)
        .collection("trick_list")
        .doc(trickId)
        .withConverter(trickConverter);

    const snapshot = tx ? await tx.get(trickRef) : await trickRef.get();

    if (!snapshot.exists) {
        return null;
    }

    return snapshot.data()!;
}

/* 3. Trick Item ======================================================= */

const trickItemConverter: FirestoreDataConverter<TrickItem> = {
    toFirestore(trickItem: TrickItem) {
        return trickItem;
    },
    fromFirestore(snapshot: QueryDocumentSnapshot): TrickItem {
        return snapshot.data() as TrickItem;
    },
};

export async function fetchTrickItemById(
    userId: string,
    trickItemId: string,
    tx?: Transaction,
): Promise<TrickItem | null> {
    const trickItemRef = db
        .collection("users")
        .doc(userId)
        .collection("trick_items")
        .doc(trickItemId)
        .withConverter(trickItemConverter);

    const snapshot = tx
        ? await tx.get(trickItemRef)
        : await trickItemRef.get();

    if (!snapshot) {
        return null;
    }

    return snapshot.data()!;
}

/* 4. POST ======================================================= */

const postConverter: FirestoreDataConverter<Post> = {
    toFirestore(post: Post) {
        return post;
    },
    fromFirestore(snapshot: QueryDocumentSnapshot): Post {
        return snapshot.data() as Post;
    },
};

export async function fetchPostById(
    postId: string,
    tx?: Transaction,
): Promise<Post | null> {
    const postRef = db
        .collection("posts")
        .doc(postId)
        .withConverter(postConverter);

    const snapshot = tx ? await tx.get(postRef) : await postRef.get();

    if (!snapshot) {
        console.log("SNAPSHOT NULL");
        return null;
    }

    return snapshot.data()!;
}

export async function decrementPostCommentCount(
    postId: string,
    value: number = 1,
) {
    const postRef = db.collection("posts").doc(postId);

    const snapshot = await postRef.get();
    if (!snapshot.exists) return;

    await postRef.update({
        comment_count: FieldValue.increment(-value),
    });
}

/* 5. COMMENT ======================================================= */

const commentConverter: FirestoreDataConverter<Comment> = {
    toFirestore(comment: Comment) {
        return comment;
    },
    fromFirestore(snapshot: QueryDocumentSnapshot): Comment {
        return snapshot.data() as Comment;
    },
};

export async function fetchCommentById(
    postId: string,
    commentId: string,
    tx?: Transaction,
): Promise<Comment | null> {
    const commentRef = db
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .doc(commentId)
        .withConverter(commentConverter);

    const snapshot = tx
        ? await tx.get(commentRef)
        : await commentRef.get();

    if (!snapshot) {
        return null;
    }

    return snapshot.data()!;
}
