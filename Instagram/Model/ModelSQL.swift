//
//  ModelSQL.swift
//  Instagram
//
//  Created by Ronen on 12/03/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation
import SQLite

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
//            dropTables()
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
        UserModel.drop(database: database)
//        Comment.drop(database: database)
        LastUpdateDates.drop(database: database)
    }
    
    
}
