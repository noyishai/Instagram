//
//  Notification.swift
//  Instagram
//
//  Created by Noy Ishai on 07/02/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation
import FirebaseAuth
class Notification {
    var from: String?
    var objectId: String?
    var type: String?
    var timestamp: Int?
    var id: String?
}


extension Post {
    // Static func to let us use this transform without creating notification instance
    static func transform(dict: [String: Any], key: String) -> Notification {
        let notification = Notification()
        notification.id = key
        notification.objectId = dict["objectId"] as? String
        notification.type = dict["type"] as? String
        notification.timestamp = dict["timestamp"] as? Int
        return notification
    }
}
