//
//  UploadBaseCommentRequest.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/7/26.
//

import Foundation

struct UploadBaseCommentRequest {
    let post: Post
    let content: String
    let user: User
}
