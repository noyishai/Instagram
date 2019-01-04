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
    var uid: String?
    var id: String?
}

// Extension to Post which will replace inits for more clear coding instead of overriding inits
extension Post {
    // Static func to let us use this transform without creating Post instance
    static func transformPostPhoto(dict: [String: Any], key: String) -> Post {
        let post = Post()
        post.id = key
        post.caption = dict["caption"] as? String // The extracted caption from Firebase Database
        post.photoUrl = dict["photoUrl"] as? String // The extracted photoUrl from Firebase Database
        post.uid = dict["uid"] as? String // The extracted UID from Firebase Database
        return post
    }
    
    static func transformPostVideo() {
    }
}
