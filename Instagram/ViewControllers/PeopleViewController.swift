//
//  PeopleViewController.swift
//  Instagram
//
//  Created by Noy Ishai on 06/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

class PeopleViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var users: [UserModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        loadUsers()
    }
    
    func loadUsers(){
        Api.User.observeUsers {(user) in
            self.isFollowing(userId: user.id!, completed: {
                (value) in
                user.isFollowing = value
                self.users.append(user)
                self.tableView.reloadData()
            })
           
        }
    }
    func isFollowing(userId:String, completed: @escaping (Bool) -> Void){
        Api.Follow.isFollowing(userId: userId, completed: completed)
        }
    
}

extension PeopleViewController: UITableViewDataSource {
    // Sets the number of tableView rows to be the number of posts stored in the Firebase Database
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    // Defines how each cell of the tableView should look like
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleTableViewCell", for: indexPath) as! PeopleTableViewCell
        let user = users[indexPath.row]
        cell.user = user

        return cell
    }
}
