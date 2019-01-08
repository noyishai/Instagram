//
//  PeopleTableViewCell.swift
//  Instagram
//
//  Created by Noy Ishai on 07/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

class PeopleTableViewCell: UITableViewCell {
   

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var user: UserModel?{
        didSet {
            updateView()
        }
    }
    
    func updateView(){
        nameLable.text = user?.username
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImg"))
        }
        
        Api.Follow.isFollowing(userId: user!.id!){(value) in
            if value {
                self.configureUnFollowButton()
            } else {
                self.configureFollowButton()
            }
        }
        
/*        if user!.isFollowing! == true {
            configureUnFollowButton()
        } else {
            configureFollowButton()
        }*/
        
    }
        
    func configureFollowButton(){
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232.255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        
        followButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        followButton.backgroundColor = UIColor(red: 69/255, green: 142/255, blue: 255/255, alpha: 1)
        self.followButton.setTitle("Follow", for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(self.followAction), for: UIControlEvents.touchUpInside)
    }
    func configureUnFollowButton(){
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232.255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        
        followButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        followButton.backgroundColor = UIColor.clear
        self.followButton.setTitle("Following", for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(self.unFollowAction), for: UIControlEvents.touchUpInside)
    }
    
    func followAction(){
       Api.Follow.followAction(withUser: user!.id!)
        configureUnFollowButton()
    }
    
    func unFollowAction(){
       Api.Follow.unFollowAction(withUser: user!.id!)
       configureFollowButton()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
