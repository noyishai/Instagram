//
//  ProfileViewController.swift
//  Instagram
//
//  Created by admin on 18/12/2018.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: User!
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        fetchUser()
        fetchMyPosts()
    }
    
    // Getting the current user
    func fetchUser() {
        Api.User.observeCurrentUser { (user) in
            self.user = user
            self.collectionView.reloadData()
        }
    }
    
    // Query the posts shared by the user
    func fetchMyPosts() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        // Gets posts keys shared by the user
        Api.MyPosts.REF_MY_POSTS.child(currentUser.uid).observe(.childAdded, with: { snapshot in
            Api.Post.observePost(withId: snapshot.key, completion: { (post: Post) in
                self.posts.append(post)
                self.collectionView.reloadData()
            })
        })
    }
}

extension ProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderProfileCollectionReusableView", for: indexPath) as! HeaderProfileCollectionReusableView
        if let user = self.user {
            headerViewCell.user = user
        }
        return headerViewCell
    }
}
