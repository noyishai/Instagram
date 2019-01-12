//
//  HelperService.swift
//  Instagram
//
//  Created by Ronen on 05/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase

class HelperService {
    
    // Uploades the data to Firebase storage and database
    static func uploadDataToServer(data: Data, caption: String, onSuccess: @escaping () -> Void) {
        let photoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("posts").child(photoIdString)
        storageRef.putData(data, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return // error
            }
            storageRef.downloadURL( completion: { (url, error) in
                if error != nil {
                    return // error
                }
                guard let photoUrl = url?.absoluteString else { return }
                self.sendDataToDatabase(photoUrl: photoUrl, caption: caption, onSuccess: onSuccess)
            })
        })
    }
    
    static func sendDataToDatabase(photoUrl: String, caption: String, onSuccess: @escaping () -> Void) {
        let newPostId = Api.Post.REF_POSTS.childByAutoId().key
        let newPostReference = Api.Post.REF_POSTS.child(newPostId!)
        
        guard let currentUser = Api.User.CURRENT_USER else { return }
        
        let currentUserId = currentUser.uid
        newPostReference.setValue(["uid": currentUserId, "photoUrl": photoUrl, "caption": caption, "likesCount": 0], withCompletionBlock: { (error, ref) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            Api.Feed.REF_FEED.child("feed").child(Api.User.CURRENT_USER!.uid).child(newPostId!).setValue(true)
            
            
            let myPostRef = Api.MyPosts.REF_MY_POSTS.child(currentUserId).child(newPostId!)
            myPostRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            })
            
            
            ProgressHUD.showSuccess("Photo Uploaded")
            onSuccess()
        })
        
    }
}
