//
//  SettingTableViewController.swift
//  Instagram
//
//  Created by Noy Ishai on 17/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var usernameTextFiled: UITextField!
    @IBOutlet weak var emailTextFiled: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Edit Profile"
        fetchCurrentUser()
    }

    func fetchCurrentUser(){
        Api.User.observeCurrentUser {(user)in
            self.usernameTextFiled.text = user.username
            self.emailTextFiled.text = user.email
            if let profileUrl = URL(string: user.profileImageUrl!){
                self.profileImageView.sd_setImage(with: profileUrl)
            }
        }
    }
    
}
