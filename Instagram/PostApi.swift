//
//  PostApi.swift
//  Instagram
//
//  Created by Ronen on 04/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation
import FirebaseDatabase

class PostApi {
    var REF_POSTS = Database.database().reference().child("posts")
    
    // Gets the posts and observes for new ones
    func observePosts(completion: @escaping (Post) -> Void) {
        REF_POSTS.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            // Creates dictionary from the database loaded from Firebase
            if let dict = snapshot.value as? [String: Any] {
                let newPost = Post.transformPostPhoto(dict: dict, key: snapshot.key) // snapshot.key returns the post id which firebase created
                completion(newPost)
            }
        }
    }
    
    // Gets post by id
    func observePost(withId id: String, completion: @escaping (Post) -> Void) {
        REF_POSTS.child(id).observeSingleEvent(of: DataEventType.value) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let post = Post.transformPostPhoto(dict: dict, key: snapshot.key)
                completion(post)
            }
        }
    }
}
