//
//  HashTagApi.swift
//  Instagram
//
//  Created by Ronen on 06/02/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation
import FirebaseDatabase

class HashTagApi {
    var REF_HASHTAG = Database.database().reference().child("hashTag")
}
