//
//  HomeiewController.swift
//  Instagram
//
//  Created by admin on 18/12/2018.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var posts = [Post]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Lets the tableView estimight it's height for better performance
        tableView.estimatedRowHeight = 521
        // Lets the cells to automatic adjust it's size based on it's content
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        loadPosts()
    }
    
    @IBAction func logout_TouchUpInside(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Start", bundle: nil)
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            self.present(signInVC, animated: true, completion: nil)
        } catch let logoutError {
            print(logoutError)
        }
    }
    
    // Load posts and observe for new added posts and ignore unchanged posts
    func loadPosts() {
        Database.database().reference().child("posts").observe(.childAdded) { (snapshot: DataSnapshot) in
            // Creates dictionary from the database loaded from Firebase
            if let dict = snapshot.value as? [String: Any] {
                let newPost = Post.transformPostPhoto(dict: dict)
                self.posts.append(newPost)
                self.tableView.reloadData()
            }
        }
        
    }
    
}

extension HomeViewController: UITableViewDataSource {
    // Sets the number of tableView rows to be the number of posts stored in the Firebase Database
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return posts.count
        return 10
    }
    
    // Defines how each cell of the tableView should look like
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! HomeTableViewCell
        cell.profileImageView.image = UIImage(named: "photo1.jpeg")
        cell.nameLabel.text = "Ronen"
        cell.postImageView.image = UIImage(named: "photo2.jpeg")
        cell.captionLabel.text = "Short TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort TextShort Text"
//        cell.textLabel?.text = posts[indexPath.row].caption
        return cell
    }
}
