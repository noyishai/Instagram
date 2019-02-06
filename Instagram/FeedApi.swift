//
//  FeedApi.swift
//  Instagram
//
//  Created by Noy Ishai on 09/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation
import FirebaseDatabase
class FeedApi{
    var REF_FEED = Database.database().reference().child("feed")
    
    // Gets the feed and observes for new posts addedd to it
    func observeFeed(withId id:String, completion: @escaping (Post) -> Void){
        REF_FEED.child(id).observe(.childAdded, with: {
            snapshot in
            let key = snapshot.key
            Api.Post.observePost(withId: key, completion: { (post)
                in
                completion(post)
            })
        })
    }
    
    //will control the post that remove after the unfollow action
    //each remove will return in a snapshot
    func observeFeedRemoved(withId id: String, completion: @escaping (Post) -> Void){
        REF_FEED.child(id).observe(.childRemoved, with: {
            snapshot in
            let key = snapshot.key
            Api.Post.observePost(withId: key, completion: { (post) in
                completion(post)
            })
        })
    }
    
}
