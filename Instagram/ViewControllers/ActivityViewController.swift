//
//  ActivityViewController.swift
//  Instagram
//
//  Created by admin on 18/12/2018.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ActivityViewController: UITableViewDataSource{
    // Sets the number of tableView rows to be the number of posts stored in the Firebase Database
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    // Defines how each cell of the tableView should look like
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell", for: indexPath) as! ActivityTableViewCell
        cell.nameLabel.text = "noyi"
        cell.profileImage.image = UIImage(named: "placeholderImg")
        return cell
    }
}
