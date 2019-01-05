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
    
}
