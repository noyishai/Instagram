//
//  AuthService.swift
//  Instagram
//
//  Created by Ronen Zolicha on 01/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class AuthService {
    
    // Firebase sign in with two escaping, one for success login and one for failed login
    static func signIn(email: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (authDataResult:AuthDataResult?, error:Error?) in
            if error != nil {
                onError(error!.localizedDescription)
                return // Error
            }
            onSuccess()
        })
    }
    
    // Firebase sign up wutih two escaping, one for success sigh up and one for failed sigh up
    static func signUp(username: String, email: String, password: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        // need to move to FIrebase Model
        
        // Creates user at Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: password, completion: { (authDataResult:AuthDataResult?, error:Error?) in
            if error != nil {
                onError(error!.localizedDescription)
                return // error
            }
            let uid = authDataResult?.user.uid
            let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("profile_image").child(uid!)
            
            // Puts the profile image into Firebase Storage
            storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    return // error
                }
                storageRef.downloadURL( completion: { (url, error) in
                    if error != nil {
                        return // error
                    }
                    guard let profileImageUrl = url?.absoluteString else { return }
                    self.setUserInformation(profileImageUrl: profileImageUrl, username: username, email: email, uid: uid!, onSuccess: onSuccess)
                })
            })
        })
    }
    
    // Sets the user information
    static func setUserInformation(profileImageUrl: String, username: String, email: String, uid: String, onSuccess: @escaping () -> Void) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users")
        let newUserReference = usersReference.child(uid)
        newUserReference.setValue(["username": username, "email": email, "profileImageUrl": profileImageUrl])
        onSuccess()
    }
    
    static func logout(onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        do {
            try Auth.auth().signOut()
            onSuccess()
        } catch let logoutError {
            onError(logoutError.localizedDescription)
        }
    }
    
}
