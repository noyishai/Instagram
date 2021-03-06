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
    static func uploadDataToServer(data: Data,ratio: CGFloat , caption: String, onSuccess: @escaping () -> Void) {
        uploadImageToFirebaseStorage(data: data) { (photoUrl: String) in
            self.sendDataToDatabase(photoUrl: photoUrl, ratio: ratio, caption: caption, onSuccess: onSuccess)
        }
    }
    
    // Uploads images to Firebase Storage
    static func uploadImageToFirebaseStorage(data: Data, onSuccess: @escaping (_ imageUrl: String) -> Void) {
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
                onSuccess(photoUrl)
            })
        })
    }
    
    // Sends the data to the database
    static func sendDataToDatabase(photoUrl: String,ratio: CGFloat, caption: String, onSuccess: @escaping () -> Void) {
        let newPostId = Api.Post.REF_POSTS.childByAutoId().key
        let newPostReference = Api.Post.REF_POSTS.child(newPostId!)
        
        guard let currentUser = Api.User.CURRENT_USER else { return }
        
        let currentUserId = currentUser.uid
        
        // Creats "words" array and seperate them into "word" to look for HashTags (#)
        let words = caption.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        for var word in words {
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters) // Removes special characters so we wont crash
                Api.HashTag.REF_HASHTAG.child(word.lowercased()).child(newPostId!).setValue(true)
//                newHashTagRef.updateChildValues([newPostId: true])
            }
        }
        //will present the current time
        let timestamp = Int(Date().timeIntervalSince1970)
        
        
        // Creats post reference
        newPostReference.setValue(["uid": currentUserId, "photoUrl": photoUrl, "caption": caption, "likesCount": 0, "ratio": ratio, "timestamp": timestamp ], withCompletionBlock: { (error, ref) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            Api.Feed.REF_FEED.child(Api.User.CURRENT_USER!.uid).child(newPostId!).setValue(["timestamp" : timestamp])
            //When user will upload a new post all his followers can view it on real time.
            Api.Follow.REF_FOLLOWERS.child(Api.User.CURRENT_USER!.uid).observeSingleEvent(of: .value, with: {
                snapshot in
                let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
                arraySnapshot.forEach({ (child) in
                    print(child.key)
                    Api.Feed.REF_FEED.child(child.key).child(newPostId!).setValue(["timestamp" : timestamp])
                    let newNotificationId = Api.Notification.REF_NOTIFICATION.child(child.key).childByAutoId().key
                    let newNotificatioReference = Api.Notification.REF_NOTIFICATION.child(child.key).child(newNotificationId!)
                    newNotificatioReference.setValue(["from": Api.User.CURRENT_USER!.uid, "type": "feed", "objectId": newPostId!, "timestamp": timestamp])
                })
            })
            
            // Creats post-feed reference
            let myPostRef = Api.MyPosts.REF_MY_POSTS.child(currentUserId).child(newPostId!)
            myPostRef.setValue(["timestamp" : timestamp], withCompletionBlock: { (error, ref) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            })
            ProgressHUD.showSuccess("Photo Uploaded")
            onSuccess()
        })
    }
    
    /// File handling
    static func saveImageToFile(image:UIImage, name:String){
        if let data = image.jpegData(compressionQuality: 0.8){
            let filename = getDocumentsDirectory().appendingPathComponent(name)
            try? data.write(to: filename)
        }
    }
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in:
            .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    static func getImageFromFile(name:String)->UIImage?{
        let filename = getDocumentsDirectory().appendingPathComponent(name)
        return UIImage(contentsOfFile:filename.path)
    }
    
    static func getImageFromFirebase(url:String, callback:@escaping (UIImage?)->Void){
        let ref = Storage.storage().reference(forURL: url)
        ref.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if error != nil {
                callback(nil)
            } else {
                let image = UIImage(data: data!)
                callback(image)
            }
        }
    }
}
