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
        followButton.addTarget(self, action: #selector(self.followAction), for: UIControlEvents.touchUpInside)
        followButton.addTarget(self, action: #selector(self.unFollowAction), for: UIControlEvents.touchUpInside)
    }
    
    func followAction(){
        Api.Follow.REF_FOLLOWERS.child(user!.id!).child(Api.User.CURRENT_USER!.uid).setValue(true)
        Api.Follow.REF_FOLLOWERS.child(Api.User.CURRENT_USER!.uid).child(user!.id!).setValue(true)
    }
    
    func unFollowAction(){
        Api.Follow.REF_FOLLOWERS.child(user!.id!).child(Api.User.CURRENT_USER!.uid).setValue(NSNull())
        Api.Follow.REF_FOLLOWERS.child(Api.User.CURRENT_USER!.uid).child(user!.id!).setValue(NSNull())
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
