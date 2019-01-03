//
//  Post.swift
//  Instagram
//
//  Created by Ronen on 03/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation

class Post {
    var caption: String?
    var photoUrl: String?
}

// Extension to post which will replace inits for more clear coding instead of overriding inits
extension Post {
    // Static func to let us use this transform without creating Post instance
    static func transformPostPhoto(dict: [String: Any]) -> Post {
        let post = Post()
        post.caption = dict["caption"] as? String // The extracted caption from the snapshot
        post.photoUrl = dict["photoUrl"] as? String // The extracted photoUrl from the snapshot
        return post
    }
    
    static func transformPostVideo(dict: [String: Any]) -> Post {
        let post = Post()
        post.caption = dict["caption"] as? String // The extracted caption from the snapshot
        post.photoUrl = dict["photoUrl"] as? String // The extracted photoUrl from the snapshot
        return post
    }
}
