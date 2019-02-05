//
//  DiscoverViewController.swift
//  Instagram
//
//  Created by admin on 18/12/2018.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {
  
    @IBOutlet weak var collectionView: UICollectionView!
    var posts: [Post] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        loadTopPosts()
    }
    
    @IBAction func refresh_TouchUp(_ sender: Any) {
        loadTopPosts()
    }
    
    //the most popular post will show first
    func loadTopPosts(){
        ProgressHUD.show("Loading...", interaction: false)
        self.posts.removeAll()
        self.collectionView.reloadData()
        Api.Post.observeTopPosts(completion: {(post) in
            self.posts.append(post)
            self.collectionView.reloadData()
            ProgressHUD.dismiss()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Discover_DetailSegue" {
            let detailVC = segue.destination as! DetailViewController
            let postId = sender as! String
            detailVC.postId = postId
        }
    }
}
extension DiscoverViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let post = posts[indexPath.row]
        cell.post = post
        cell.delegate=self 
        return cell
    }
}

// Extension to customize the layout of the collection view
extension DiscoverViewController: UICollectionViewDelegateFlowLayout {
    
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

extension DiscoverViewController: PhotoCollectionViewCellDelegate{
    func goToDetailVC(postId: String) {
        performSegue(withIdentifier: "Discover_DetailSegue", sender: postId)
    }
}
