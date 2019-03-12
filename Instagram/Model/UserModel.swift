//
//  User.swift
//  Instagram
//
//  Created by Ronen on 03/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation
import SQLite

class UserModel {
    var email: String?
    var profileImageUrl: String?
    var username: String?
    var id: String?
    var isFollowing: Bool?
    var lastUpdated: Double?
    
    init() {
    }
    
    init(newEmail: String, newProfileImageUrl: String, userId: String, newUsername: String) {
        email = newEmail
        profileImageUrl = newProfileImageUrl
        username = newUsername
        id = userId
    }
}

// Extension to User which will replace inits for more clear coding instead of overriding inits
extension UserModel {
    static func transformUser(dict: [String: Any], key: String) -> UserModel {
        let user = UserModel()
        user.email = dict["email"] as? String
        user.profileImageUrl = dict["profileImageUrl"] as? String
        user.username = dict["username"] as? String
        user.id = key
        return user
    }
}

// Extension to handle SQlite
extension UserModel {
    static func createTable(database: OpaquePointer?)  {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS USERS (ID TEXT PRIMARY KEY,EMAIL TEXT, PROFILEIMAGEURL TEXT, USERNAME TEXT)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return
        }
        print("USERS Table Created")
    }
    
    static func drop(database: OpaquePointer?)  {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let res = sqlite3_exec(database, "DROP TABLE USERS;", nil, nil, &errormsg);
        if(res != 0){
            print("error droping USERS table");
            return
        }
        print("USERS Table Dropped")
    }
    
    static func getAll(database: OpaquePointer?)->[UserModel]{
        var sqlite3_stmt: OpaquePointer? = nil
        var data = [UserModel]()
        if (sqlite3_prepare_v2(database,"SELECT * from USERS;",-1,&sqlite3_stmt,nil)
            == SQLITE_OK){
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                let userId = String(cString:sqlite3_column_text(sqlite3_stmt,0)!)
                let email = String(cString:sqlite3_column_text(sqlite3_stmt,1)!)
                let profileImageUrl = String(cString:sqlite3_column_text(sqlite3_stmt,2)!)
                let username = String(cString:sqlite3_column_text(sqlite3_stmt,3)!)
                data.append(UserModel(newEmail: email, newProfileImageUrl: profileImageUrl, userId: userId, newUsername: username))
            }
        }
        sqlite3_finalize(sqlite3_stmt)
        return data
    }
    
    static func addNew(database: OpaquePointer?, user: UserModel){
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO USERS(ID, EMAIL, PROFILEIMAGEURL, USERNAME) VALUES (?,?,?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            let userId = user.id!.cString(using: .utf8)
            let email = user.email!.cString(using: .utf8)
            let profileImageUrl = user.profileImageUrl!.cString(using: .utf8)
            let username = user.username!.cString(using: .utf8)
            
            
            sqlite3_bind_text(sqlite3_stmt, 1, userId,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, email,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 3, profileImageUrl,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 4, username,-1,nil);
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new user row added succefully")
            }
        }
        sqlite3_finalize(sqlite3_stmt)
    }
    
    static func get(database: OpaquePointer?, byId:String)->UserModel?{
        return nil;
    }
    
    static func getLastUpdateDate(database: OpaquePointer?)->Double{
        return LastUpdateDates.get(database: database, tableName: "users")
    }
    
    static func setLastUpdateDate(database: OpaquePointer?, date:Double){
        LastUpdateDates.set(database: database, tableName: "users", date: date);
    }
}


