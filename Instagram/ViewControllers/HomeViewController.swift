//
//  HomeiewController.swift
//  Instagram
//
//  Created by admin on 18/12/2018.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit
import SDWebImage

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var posts = [Post]()
    var users = [UserModel]()
    var isLoadingPost = false
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Lets the tableView estimight it's height for better performance
        tableView.estimatedRowHeight = 521
        // Lets the cells to automatic adjust it's size based on it's content
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        refreshControl.addTarget(self, action:#selector(refresh),for: .valueChanged)
        tableView.addSubview(refreshControl)
        activityIndicatorView.startAnimating()
        loadPosts()
    }
    
    @objc func refresh() {
        posts.removeAll()
        users.removeAll()
        loadPosts()
    }
    
    // Load posts and observe for new added posts and ignore unchanged posts
    func loadPosts() {

        // Observe feed to get all posts and not limited
//        Api.Feed.observeFeed(withId: Api.User.CURRENT_USER!.uid) { (post) in
//            guard let postUid = post.uid else {
//                return
//            }
//            self.fetchUser(uid: postUid, completed: {
//                self.posts.insert(post, at: 0)
//                self.tableView.reloadData()
//            })
//        }
        
        isLoadingPost = true
        Api.Feed.getRecentFeed(withId: Api.User.CURRENT_USER!.uid, start: posts.first?.timestamp, limit: 3) { (results) in
            if results.count > 0 {
                results.forEach({ (result) in
                    self.posts.append(result.0)
                    self.users.append(result.1)
                })
            }
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            self.isLoadingPost = false
            self.activityIndicatorView.stopAnimating()
            self.tableView.reloadData()
        }
    }
    
    // Given user ID gives the data
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        Api.User.observeUser(withId: uid, completion: {
            user in
            self.users.insert(user, at: 0)
            completed()
        })
    }
    
    // Segues of the protocol
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentSegue" {
            let commentVC = segue.destination as! CommentViewController
            let postId = sender as! String
            commentVC.postId = postId
        }
        
        if segue.identifier == "Home_ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }
        
        if segue.identifier == "Home_HashTagSegue" {
            let hashTagVC = segue.destination as! HashTagViewController
            let tag = sender as! String
            hashTagVC.tag = tag
        }
    }
}

// Extenstion to specifiy how the tableview will be
// Extension to let the home feed scoll load new posts
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    // Sets the number of tableView rows to be the number of posts stored in the Firebase Database
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if posts.isEmpty {
            return 0
        }
        return posts.count
    }
    
    // Defines how each cell of the tableView should look like
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! HomeTableViewCell
        if posts.isEmpty {
            return UITableViewCell()
        }
        let post = posts[indexPath.row]
        let user = users[indexPath.row]
        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
            
            guard !isLoadingPost else {
                return
            }
            isLoadingPost = true
            
            guard let lastPostTimestamp = self.posts.last?.timestamp else {
                isLoadingPost = false
                return
            }
            Api.Feed.getOldFeed(withId: Api.User.CURRENT_USER!.uid, start: lastPostTimestamp, limit: 5) { (results) in
                if results.count == 0 {
                    return
                }
                for result in results {
                    self.posts.append(result.0)
                    self.users.append(result.1)
                }
                self.tableView.reloadData()
                self.isLoadingPost = false
            }
            
        }
    }
}


// Home addaptations for the protocols
extension HomeViewController: HomeTableViewCellDelegate{
    func goToCommentVC(postId: String) {
        performSegue(withIdentifier: "CommentSegue", sender: postId)
    }
    
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Home_ProfileSegue", sender: userId)
    }
    
    func goToHashTag(tag: String) {
        performSegue(withIdentifier: "Home_HashTagSegue", sender: tag)
    }
}
