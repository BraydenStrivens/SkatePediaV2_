//
//  CommentStore.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/27/26.
//

import Foundation

@MainActor
final class CommentStore: ObservableObject {
    @Published private(set) var baseComments: [Comment] = []
    @Published private(set) var repliesByBaseId: [String: [Comment]] = [:]
    
    private var baseCommentIds: Set<String> = []
    private var replyIdsByBaseId: [String: Set<String>] = [:]
    
    private let postId: String
    
    init(postId: String) {
        self.postId = postId
    }
    
    func allRepliesFetched(for baseCommentId: String) -> Bool {
        let replyCount = baseComments.first(where: { $0.id == baseCommentId })?.replyCount
        let fetchedCount = repliesByBaseId[baseCommentId, default: []].count
        return replyCount == fetchedCount
    }
    
    func replies(for baseCommentId: String) -> [Comment] {
        repliesByBaseId[baseCommentId] ?? []
    }
    
    func addBaseComment(_ newBaseComment: Comment) {
        if baseCommentIds.insert(newBaseComment.id).inserted {
            baseComments.insert(newBaseComment, at: 0)
        }
    }
    
    func addBaseCommentBatch(_ currentBatch: [Comment]) {
        for baseComment in currentBatch {
            if baseCommentIds.insert(baseComment.id).inserted {
                baseComments.append(baseComment)
            }
        }
    }
    
    func removeBaseComment(_ toRemoveId: String) {
        baseCommentIds.remove(toRemoveId)
        baseComments.removeAll(where: { $0.id == toRemoveId })
        
        repliesByBaseId.removeValue(forKey: toRemoveId)
        replyIdsByBaseId.removeValue(forKey: toRemoveId)
    }
    
    func addReply(_ newReply: Comment) {
        guard
            let parentId = newReply.replyingToData?.commentId,
            let baseCommentId = newReply.baseCommentId
        else { return }
                
        if replyIdsByBaseId[baseCommentId, default: []].insert(newReply.id).inserted {
            let insertIndex = insertNewReplyIndex(
                for: parentId,
                sortedReplies: repliesByBaseId[baseCommentId, default: []]
            )

            repliesByBaseId[baseCommentId, default: []].insert(newReply, at: insertIndex)
        }
    }
    
    func addReplyBatch(for baseCommentId: String, _ currentBatch: [Comment]) {
        var existingReplies = replies(for: baseCommentId)

        for reply in currentBatch {
            if replyIdsByBaseId[baseCommentId, default: []].insert(reply.id).inserted {
                existingReplies.append(reply)
            }
        }
        
        repliesByBaseId[baseCommentId, default: []] = orderReplies(
            baseCommentId: baseCommentId,
            replies: existingReplies
        )
    }
    
    func removeReply(_ toRemove: Comment) {
        guard let baseCommentId = toRemove.baseCommentId else { return }
        replyIdsByBaseId[baseCommentId]?.remove(toRemove.id)
        repliesByBaseId[baseCommentId]?.removeAll(where: { $0.id == toRemove.id })
    }
    
    func updateBaseCommentReplyCount(
        for baseCommentId: String?,
        increment: Bool = true
    ) {
        guard
            let baseCommentId,
            let index = baseComments.firstIndex(where: { $0.id == baseCommentId })
        else { return }
                
        var updated = baseComments[index]
        guard let currentReplyCount = updated.replyCount else { return }
        
        let incrementValue: Int = increment ? 1 : -1
        updated.replyCount = currentReplyCount + incrementValue
        baseComments[index] = updated
    }
    
    private func insertNewReplyIndex(
        for parentId: String,
        sortedReplies: [Comment]
    ) -> Int {
        guard let startIndex = sortedReplies.firstIndex(where: { $0.commentId == parentId }) else {
            return sortedReplies.count
        }
        
        var insertIndex = startIndex + 1
        
        while insertIndex < sortedReplies.count &&
                isDescendant(of: parentId, candidate: sortedReplies[insertIndex]) {
            insertIndex += 1
        }
        
        func isDescendant(of parentId: String, candidate: Comment) -> Bool {
            return candidate.replyingToData?.commentId == parentId
        }
        
        return insertIndex
    }
    
    /// Orders a comments replies so that if any reply has replies, those replies are listed right beneath it in order of their upload date..
    /// Orders array of replies as show:
    ///
    /// Base Comment:
    ///     L   Reply1 (reply to a base comment)
    ///     L   Reply2
    ///     |       L   Reply2.1 (Reply1 to Reply2)
    ///     |       |       L   Reply2.1.1 (Reply1 to Reply2.1)
    ///     |       L   Reply2.2
    ///     L   Reply3
    ///     |       L   Reply3.1
    ///     L   Reply4
    ///     ...
    ///
    /// Starts by grouping the replies into a dictionary where the key is a "commentId" and the value is an array of comments that are replies to that commentId.
    /// Each comment is a child to either the base comment or a reply comment. If a comment has replies, it becomes a parent with its replies being it's children.
    ///
    /// From:       replies = [
    ///             ( id: "r1",       replyTo: "base" )
    ///             ( id: "r2",       replyTo: "base" )
    ///             ( id: "r2.1",    replyTo: "r2" )
    ///             ( id: "r1.1",    replyTo: "r1" )
    ///             ( id: "r2.1.1", replyTo: "r2.1" )
    ///         ]
    ///
    /// To:             childrenByParents : [ "commentId" : [Replies] ] = [
    ///             "base" : [ "r1" , "r2" ]
    ///             "r1"      : [ "r1.1" ]
    ///             "r2"      : [ "r2.1" ]
    ///             "r2.1"   : [ "r2.1.1" ]
    ///         ]
    ///
    /// Then uses Depth First Traversal to traverse the childrenByParents dictionary starting at the base, and appends the replies to an array in order.
    /// - The first child in the base is "r1":
    ///       1.   "r1"           -->   append("r1")          -->   traverse childrenByParents["r1"]
    ///       2.   "r1.1"        -->   append("r1.1")       -->   childrenByParents["r1.1"] does not exist and "r1" has no more children
    ///       3.   "r2"           -->   append("r2")          -->   traverse childrenByParents["r2"]
    ///       4.   "r2.1"        -->   append("r2.1")       -->   traverse childrenByParents["r2.1"]
    ///       5.   "r2.1.1"     -->   append("r2.1.1")    -->   end
    ///
    /// - Parameters:
    ///  - baseCommentId: The 'commentId' of a base comment for which the replies belong to.
    ///  - replies: An array of 'Comment' objects representing replies to a base comment.
    ///
    /// - Returns: An array of comment replies ordered by their upload date and the comments they are replying to.
    ///
    func orderReplies(baseCommentId: String, replies: [Comment]) -> [Comment] {
        // 1. Groups the replies by the parentId
        var childrenByParent: [String : [Comment]] = [:]
        for reply in replies {
            guard let replyingToId = reply.replyingToData?.commentId else {
                continue
            }
            childrenByParent[replyingToId, default: []].append(reply)
            
        }
        
        // Final sorted replies array
        var result: [Comment] = []

        func depthFirstTraverse(parentId: String) {
            // Verifies the parent has children
            guard let children = childrenByParent[parentId] else { return }

            // Sorts children by the date they were uploaded
            let sortedChildren = children.sorted { $0.dateCreated < $1.dateCreated}
            
            for child in sortedChildren {
                result.append(child)
                // The child becomes a parent and is searched for children
                depthFirstTraverse(parentId: child.commentId)
            }
        }
        
        // Starts traversal from the base
        depthFirstTraverse(parentId: baseCommentId)
        
        return result
    }
}
