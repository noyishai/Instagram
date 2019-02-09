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
    
    // Gets the feed and observes for new posts addedd to it querying by timestamp
    func observeFeed(withId id:String, completion: @escaping (Post) -> Void){
        REF_FEED.child(id).queryOrdered(byChild: "timestamp").observe(.childAdded, with: { snapshot in
            let key = snapshot.key
            Api.Post.observePost(withId: key, completion: { (post) in
                completion(post)
            })
        })
    }
    
    // Gets the recent feed and displays limited posts
    func getRecentFeed(withId id: String, start timestamp: Int? = nil, limit: UInt, completion: @escaping ([(Post, UserModel)]) -> Void) {
        var feedQuery = REF_FEED.child(id).queryOrdered(byChild: "timestamp")
        if let latestPostTimestamp = timestamp, latestPostTimestamp > 0 {
            feedQuery = feedQuery.queryStarting(atValue: latestPostTimestamp + 1, childKey: "timestamp").queryLimited(toLast: limit)
        } else {
            feedQuery = feedQuery.queryLimited(toLast: limit)
        }
        var results: [(post: Post, user: UserModel)] = []
        feedQuery.observeSingleEvent(of: DataEventType.value) { (snapshot: DataSnapshot) in
            let items = snapshot.children.allObjects as! [DataSnapshot]
            let myGroup = DispatchGroup()
            for (index, item) in items.enumerated() {
                myGroup.enter()
                Api.Post.observePost(withId: item.key, completion: { (post) in
                    Api.User.observeUser(withId: post.uid!, completion: { (user) in
                        if post.uid! == user.id {
                            results.append((post, user))
//                            results.insert((post, user), at: index)
                        }
                        print(index)
                        myGroup.leave()
                    })
                })
                myGroup.notify(queue: DispatchQueue.main, execute: {
                    results.sort(by: {$0.0.timestamp! > $1.0.timestamp!})
                    completion(results)
                })
            }
        }
    }
    
    // Gets the old feed after finished the recent feed
    func getOldFeed(withId id: String, start timestamp: Int, limit: UInt, completion: @escaping ([(Post, UserModel)]) -> Void) {
        let feedOrderQuery = REF_FEED.child(id).queryOrdered(byChild: "timestamp")
        let feedLimitedQuery = feedOrderQuery.queryEnding(atValue: timestamp - 1, childKey: "timestamp").queryLimited(toLast: limit)
        feedLimitedQuery.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            let items = snapshot.children.allObjects as! [DataSnapshot]
            let myGroup = DispatchGroup()
            var results: [(post: Post, user: UserModel)] = []
            for (index, item) in items.enumerated() {
                myGroup.enter()
                Api.Post.observePost(withId: item.key, completion: { (post) in
                    Api.User.observeUser(withId: post.uid!, completion: { (user) in
                        if post.uid! == user.id {
                            results.append((post, user))
//                            results.insert((post, user), at: index)
                        }
                        print(index)
                        myGroup.leave()
                    })
                })
                myGroup.notify(queue: DispatchQueue.main, execute: {
                    results.sort(by: {$0.0.timestamp! > $1.0.timestamp!})
                    completion(results)
                })
            }
        }
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
