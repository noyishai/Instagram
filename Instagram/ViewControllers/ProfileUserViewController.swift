//
//  ProfileUserViewController.swift
//  Instagram
//
//  Created by Noy Ishai on 12/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

class ProfileUserViewController: UIViewController {

   
    @IBOutlet weak var collectionView: UICollectionView!
    var user: UserModel!
    var posts: [Post] = []
    var userId = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        print("userId: \(userId)")
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchUser()
        fetchMyPosts()
    }
    
    func fetchUser() {
        Api.User.observeUser(withId: userId){ (user) in
            self.user = user
            self.navigationItem.title = user.username
            self.collectionView.reloadData()
            
        }
    }
    
    // Query the posts shared by the user
    func fetchMyPosts() {
        // Gets posts keys shared by the user
        Api.MyPosts.REF_MY_POSTS.child(userId).observe(.childAdded, with: { snapshot in
            Api.Post.observePost(withId: snapshot.key, completion: { (post: Post) in
                self.posts.append(post)
                self.collectionView.reloadData()
            })
        })
    }
}

extension ProfileUserViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let post = posts[indexPath.row]
        cell.post = post
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

// Extension to customize the layout of the collection view
extension ProfileUserViewController: UICollectionViewDelegateFlowLayout {
    
    // Specify the spacing between rows in the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    // Specifiy the spacing between inernal items, for this case the photo cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // Specifiy the size of the rows in the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3 - 1, height: collectionView.frame.size.height / 3 - 1)
    }
}
