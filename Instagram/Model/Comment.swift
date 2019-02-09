//
//  Comment.swift
//  Instagram
//
//  Created by Ronen on 04/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation
import SQLite

class Comment {
    var commentText: String?
    var uid: String?
    var lastUpdate: Double?
    
    init() {
    }
    
    init(newCommentText: String, userId: String) {
        commentText = newCommentText
        uid = userId
    }
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

// Extension to handle SQlite
extension Comment {
    static func createTable(database: OpaquePointer?)  {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS COMMENTS (COMMENTTEXT TEXT, UID TEXT)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return
        }
    }
    
    static func drop(database: OpaquePointer?)  {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let res = sqlite3_exec(database, "DROP TABLE COMMENTS;", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return
        }
    }
    
    static func getAll(database: OpaquePointer?)->[Comment]{
        var sqlite3_stmt: OpaquePointer? = nil
        var data = [Comment]()
        if (sqlite3_prepare_v2(database,"SELECT * from COMMENTS;",-1,&sqlite3_stmt,nil)
            == SQLITE_OK){
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                let commentText = String(cString:sqlite3_column_text(sqlite3_stmt,0)!)
                let userId = String(cString:sqlite3_column_text(sqlite3_stmt,1)!)
                data.append(Comment(newCommentText: commentText, userId: userId))
            }
        }
        sqlite3_finalize(sqlite3_stmt)
        return data
    }
    
    static func addNew(database: OpaquePointer?, comment: Comment){
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO COMMENTS(COMMENTTEXT, UID) VALUES (?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            let commentText = comment.commentText!.cString(using: .utf8)
            let userId = comment.uid!.cString(using: .utf8)
            
            sqlite3_bind_text(sqlite3_stmt, 1, commentText,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, userId,-1,nil);
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new row added succefully")
            }
        }
        sqlite3_finalize(sqlite3_stmt)
    }
    
    static func get(database: OpaquePointer?, byId:String)->Comment?{
        return nil;
    }
    
    static func getLastUpdateDate(database: OpaquePointer?)->Double{
        return LastUpdateDates.get(database: database, tableName: "comments")
    }
    
    static func setLastUpdateDate(database: OpaquePointer?, date:Double){
        LastUpdateDates.set(database: database, tableName: "comments", date: date);
    }
}

