//
//  CommentViewController.swift
//  Instagram
//
//  Created by Ronen on 03/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true // Hides the tabBar
    }

}
