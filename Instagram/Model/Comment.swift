//
//  Comment.swift
//  Instagram
//
//  Created by Ronen on 04/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation

class Comment {
    var commentText: String?
    var uid: String?
}

// Extension to Comment which will replace inits for more clear coding instead of overriding inits
extension Comment {
    // Static func to let us use this transform without creating Post instance
    static func transformComment(dict: [String: Any]) -> Comment {
        let comment = Comment()
        comment.commentText = dict["commentText"] as? String // The extracted comment from Firebase Database
        comment.uid = dict["uid"] as? String // The extracted UID from Firebase Database
        return comment
    }

}
