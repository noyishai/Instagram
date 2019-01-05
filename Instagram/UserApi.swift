//
//  UserApi.swift
//  Instagram
//
//  Created by Ronen on 04/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class UserApi {
    var REF_USERS = Database.database().reference().child("users")
    
    // Gets the users and observes for new ones
    func observeUser(withId uid: String, completion: @escaping (User) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: DataEventType.value) { (snapshot: DataSnapshot) in
            // Creates dictionary from the database loaded from Firebase
            if let dict = snapshot.value as? [String: Any] {
                let user = User.transformUser(dict: dict)
                completion(user)
            }
        }
    }
    
    // Returns the current user authenticated
    func observeCurrentUser(completion: @escaping (User) -> Void) {
        guard let currentUser = Auth.auth().currentUser else { return }
        REF_USERS.child(currentUser.uid).observeSingleEvent(of: DataEventType.value) { (snapshot: DataSnapshot) in
            // Creates dictionary from the database loaded from Firebase
            if let dict = snapshot.value as? [String: Any] {
                let user = User.transformUser(dict: dict)
                completion(user)
            }
        }
    }
    
    // Returns the reference to the current user
    var REF_CURRENT_USER: DatabaseReference? {
        guard let currentUser = Auth.auth().currentUser else { return nil }
        return REF_USERS.child(currentUser.uid)
    }
    
    
}
