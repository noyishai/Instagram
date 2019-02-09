//
//  FeedApi.swift
//  Instagram
//
//  Created by Noy Ishai on 09/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SQLite

class FeedApi{
    var REF_FEED = Database.database().reference().child("feed")
    
    var modelSql = ModelSql()
    
    // Gets the feed and observes for new posts addedd to it querying by timestamp
    func observeFeed(withId id:String, completion: @escaping (Post) -> Void){
        REF_FEED.child(id).queryOrdered(byChild: "timestamp").observe(.childAdded, with: { snapshot in
            let key = snapshot.key
            Api.Post.observePost(withId: key, completion: { (post) in
                completion(post)
            })
        })
    }
    
    // Gets the recent feed and displays limited (@limit) posts
    func getRecentFeed(withId id: String, start timestamp: Int? = nil, limit: UInt, completion: @escaping ([(Post, UserModel)]) -> Void) {
        var feedQuery = REF_FEED.child(id).queryOrdered(byChild: "timestamp")
        if let latestPostTimestamp = timestamp, latestPostTimestamp > 0 {
            feedQuery = feedQuery.queryStarting(atValue: latestPostTimestamp + 1, childKey: "timestamp").queryLimited(toLast: limit)
        } else {
            feedQuery = feedQuery.queryLimited(toLast: limit)
        }
        
        var postsLastUpdated = Post.getLastUpdateDate(database: modelSql.database)
        var usersLastUpdated = Comment.getLastUpdateDate(database: modelSql.database)
        postsLastUpdated += 1
        usersLastUpdated += 1
        
        // Call Firebase API to retrieve the latest records
        feedQuery.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            let items = snapshot.children.allObjects
            let myGroup = DispatchGroup()
            var results: [(post: Post, user: UserModel)] = []
            for (_, item) in (items as! [DataSnapshot]).enumerated() {
                myGroup.enter()
                Api.Post.observePost(withId: item.key, completion: { (post) in
                    Post.addNew(database: self.modelSql.database, post: post)
                    if (post.lastUpdated != nil && post.lastUpdated! > postsLastUpdated) {
                        postsLastUpdated = post.lastUpdated!
                    }
                    Post.setLastUpdateDate(database: self.modelSql.database, date: postsLastUpdated)
                    let postsFullData = Post.getAll(database: self.modelSql.database)
                    Api.User.observeUser(withId: post.uid!, completion: { (user) in
                        UserModel.addNew(database: self.modelSql.database, user: user)
                        if (user.lastUpdated != nil && user.lastUpdated! > usersLastUpdated) {
                            usersLastUpdated = user.lastUpdated!
                        }
                        UserModel.setLastUpdateDate(database: self.modelSql.database, date: usersLastUpdated)
                        let usersFullData = UserModel.getAll(database: self.modelSql.database)
//                        for user in usersFullData {
//                            for post in postsFullData {
//                                    results.append((post, user))
//                            }
//                        }
                        if post.uid == user.id {
                            results.append((post, user))
                        }
                        //  results.insert((post, user), at: index)
                        myGroup.leave()
                    })
                })
            }
            myGroup.notify(queue: DispatchQueue.main, execute: {
                results.sort(by: {$0.0.timestamp! > $1.0.timestamp!})
                completion(results)
            })
        }
    }
    
    // Gets extra posts to the feed after you got to the bottom of the feed.
    // Limited number set to 5 means that when we will scroll down we will get new(old) limited (@limit) posts
    func getOldFeed(withId id: String, start timestamp: Int, limit: UInt, completion: @escaping ([(Post, UserModel)]) -> Void) {
        let feedOrderQuery = REF_FEED.child(id).queryOrdered(byChild: "timestamp")
        let feedLimitedQuery = feedOrderQuery.queryEnding(atValue: timestamp - 1, childKey: "timestamp").queryLimited(toLast: limit)
        
        // Call Firebase API to retrieve the latest records
        feedLimitedQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            let items = snapshot.children.allObjects as! [DataSnapshot]
            let myGroup = DispatchGroup()
            var results: [(post: Post, user: UserModel)] = []
            
            for (_, item) in items.enumerated() {
                print(item)
                myGroup.enter()
                Api.Post.observePost(withId: item.key, completion: { (post) in
                    Api.User.observeUser(withId: post.uid!, completion: { (user) in
                        if post.uid == user.id {
                            results.append((post, user))
                        }
                        myGroup.leave()
                    })
                })
            }
            myGroup.notify(queue: DispatchQueue.main, execute: {
                results.sort(by: {$0.0.timestamp! > $1.0.timestamp!})
                completion(results)
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

class ModelSql {
    var database: OpaquePointer? = nil
    
    init() {
        // initialize the DB
        let dbFileName = "localDB.db"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent(dbFileName)
            if sqlite3_open(path.absoluteString, &database) != SQLITE_OK {
                print("Failed to open db file: \(path.absoluteString)")
                return
            }
            dropTables()
            createTables()
        }
    }
    
    func createTables() {
        Post.createTable(database: database)
        UserModel.createTable(database: database)
        //        Comment.createTable(database: database)
        LastUpdateDates.createTable(database: database)
    }
    
    func dropTables(){
        Post.drop(database: database)
        UserModel.createTable(database: database)
        //        Comment.drop(database: database)
        LastUpdateDates.drop(database: database)
    }
    
    
}
