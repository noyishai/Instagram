//
//  Post.swift
//  Instagram
//
//  Created by Ronen on 03/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation
import FirebaseAuth
import SQLite

class Post {
    var caption: String?
    var photoUrl: String?
    var uid: String?
    var id: String?
    var likeCount: Int?
    var likes: Dictionary<String, Any>?
    var isLiked: Bool?
    var ratio:CGFloat?
    var timestamp: Int?
    var lastUpdated: Double?
    
    init() {
    }
    
    init(newCaption: String, newPhotoUrl: String, newUserId: String, newId: String) {
        caption = newCaption
        photoUrl = newPhotoUrl
        uid = newUserId
        id = newId
    }
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
        post.likeCount = dict["likeCount"] as? Int
        post.likes = dict["likes"] as? Dictionary<String, Any>
        post.ratio = dict["ratio"] as? CGFloat
        post.timestamp = dict["timestamp"] as? Int
        if let currentUserId = Auth.auth().currentUser?.uid {
            if post.likes != nil {
                post.isLiked = post.likes![currentUserId] != nil
            }
        }
        return post
    }
}

extension Post {
    static func createTable(database: OpaquePointer?)  {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS POSTS (ID TEXT PRIMARY KEY, CAPTION TEXT, PHOTOURL TEXT, UID TEXT)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return
        }
    }
    
    static func drop(database: OpaquePointer?)  {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let res = sqlite3_exec(database, "DROP TABLE POSTS;", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return
        }
    }
    
    static func getAll(database: OpaquePointer?)->[Post]{
        var sqlite3_stmt: OpaquePointer? = nil
        var data = [Post]()
        if (sqlite3_prepare_v2(database,"SELECT * from POSTS;",-1,&sqlite3_stmt,nil)
            == SQLITE_OK){
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                let id = String(cString:sqlite3_column_text(sqlite3_stmt,0)!)
                let caption = String(cString:sqlite3_column_text(sqlite3_stmt,1)!)
                let photoUrl = String(cString:sqlite3_column_text(sqlite3_stmt,3)!)
                let userId = String(cString:sqlite3_column_text(sqlite3_stmt,5)!)
                data.append(Post(newCaption: caption, newPhotoUrl: photoUrl, newUserId: userId, newId: id))
            }
        }
        sqlite3_finalize(sqlite3_stmt)
        return data
    }
    
    static func addNew(database: OpaquePointer?, post: Post){
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO FEED(UID, POST) VALUES (?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            let id = post.id!.cString(using: .utf8)
            let caption = post.caption!.cString(using: .utf8)
            let photoUrl = post.photoUrl!.cString(using: .utf8)
            let userId = post.uid!.cString(using: .utf8)

            sqlite3_bind_text(sqlite3_stmt, 1, id,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, caption,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 4, photoUrl,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 6, userId,-1,nil);

            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new row added succefully")
            }
        }
        sqlite3_finalize(sqlite3_stmt)
    }
    
    static func get(database: OpaquePointer?, byId:String)->Post?{
        return nil;
    }
    
    static func getLastUpdateDate(database: OpaquePointer?)->Double{
        return LastUpdateDates.get(database: database, tableName: "posts")
    }
    
    static func setLastUpdateDate(database: OpaquePointer?, date:Double){
        LastUpdateDates.set(database: database, tableName: "posts", date: date);
    }
}

