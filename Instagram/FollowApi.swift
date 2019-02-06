//
//  FollowApi.swift
//  Instagram
//
//  Created by Noy Ishai on 07/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FollowApi{
    var REF_FOLLOWERS = Database.database().reference().child("followers")
    var REF_FOLLOWING = Database.database().reference().child("following")
    
    //Update the feed location right after the current user follow someone
    //Update the the feed with the post of the follow user
    func followAction(withUser id: String) {
        Api.MyPosts.REF_MY_POSTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    Database.database().reference().child("feed").child(Api.User.CURRENT_USER!.uid).child(key).setValue(true)
                }
            }
        })
        REF_FOLLOWERS.child(id).child(Api.User.CURRENT_USER!.uid).setValue(true)
        REF_FOLLOWING.child(Api.User.CURRENT_USER!.uid).child(id).setValue(true)
    }
    
    //Remove the posts of the unfollow user from our feed
    func unFollowAction(withUser id: String) {
        
        Api.MyPosts.REF_MY_POSTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    Database.database().reference().child("feed").child(Api.User.CURRENT_USER!.uid).child(key).removeValue()
                }
            }
        })
        
        REF_FOLLOWERS.child(id).child(Api.User.CURRENT_USER!.uid).setValue(NSNull())
        REF_FOLLOWING.child(Api.User.CURRENT_USER!.uid).child(id).setValue(NSNull())
    }
    
    // Checks if the userId is following
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        REF_FOLLOWERS.child(userId).child(Api.User.CURRENT_USER!.uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let _ = snapshot.value as? NSNull {
                completed(false)
            } else {
                completed(true)
            }
        })
    }
    
    // Gets the following count of this userId
    func fetchCountFollowing(userId: String, completion: @escaping(Int) -> Void) {
        REF_FOLLOWING.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
    
    // Gets the followers count of this userId
    func fetchCountFollowers(userId: String, completion: @escaping(Int) -> Void) {
        REF_FOLLOWERS.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
}


