//
//  MyPostApi.swift
//  Instagram
//
//  Created by Ronen on 04/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation
import FirebaseDatabase

class MyPostApi {
    var REF_MY_POSTS = Database.database().reference().child("myPosts")
   
    func fetchMyPost(userId: String, completion: @escaping(String) -> Void){
        REF_MY_POSTS.child(userId).observe(.childAdded, with: {
            snapshot in
            completion(snapshot.key)
        })
    }
    
    func fetchCountMyPosts(userId: String, completion: @escaping(Int) -> Void){
        REF_MY_POSTS.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
}
