//
//  ActivityTableViewCell.swift
//  Instagram
//
//  Created by Noy Ishai on 07/02/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

protocol ActivityTableViewCellDelegate {
    func goToDetailVC(postId: String)
    func goToProfileVC(userId: String)
    func goToCommentVC(postId: String)
}

class ActivityTableViewCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var photo: UIImageView!
    
    var delegate: ActivityTableViewCellDelegate?
    
    var notification: Notification? {
        didSet {
            updateView()
        }
    }
    
    // Ovserver which wait to see if the user instance variable is set
    var user: UserModel? {
        didSet {
            setupUserInfo()
        }
    }
    
    func updateView(){
        switch notification!.type! {
        case "feed":
            descriptionLabel.text = "add a new post"
            let postId = notification!.objectId!
            Api.Post.observePost(withId: postId, completion: { (post: Post) in
                if let photoUrlString = post.photoUrl {
                    let photoUrl = URL(string: photoUrlString)
                    self.photo.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImg"))
                }
            })
            
        case "comment":
            descriptionLabel.text = "left a comment on your post"
            let objectId = notification!.objectId!
            Api.Post.observePost(withId: objectId, completion: { (post) in
                if let photoUrlString = post.photoUrl {
                    let photoUrl = URL(string: photoUrlString)
                    self.photo.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImg"))
                }
            })
            
        case "follow":
            descriptionLabel.text = "started following you"
            let objectId = notification!.objectId!
            Api.Post.observePost(withId: objectId, completion: { (post) in
                if let photoUrlString = post.photoUrl {
                    let photoUrl = URL(string: photoUrlString)
                    self.photo.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImg"))
                    
                }
            })
            
        default:
            print("")
        }
        //unwarp and print the timestamp
        //Convert the timestamp
        if let timestamp = notification?.timestamp{
            print(timestamp)
            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
            let now = Date()
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            var timeText = ""
            if diff.second! <= 0{
                timeText = "Now"
            }
            if diff.second! > 0 && diff.minute! == 0 {
                timeText = "\(diff.second!)s"
            }
            if diff.minute! > 0 && diff.hour! == 0{
                timeText = "\(diff.minute!)m"
            }
            
            if diff.hour! > 0 && diff.day! == 0{
                timeText = "\(diff.hour!)h"
            }
            if diff.day! > 0 && diff.weekOfMonth! == 0{
                timeText = "\(diff.day!)d"
            }
            if diff.weekOfMonth! > 0 {
                timeText = "\(diff.weekOfMonth!)w"
            }
            
            timeLabel.text = timeText
        }
        
        let tapGestureForPhoto = UITapGestureRecognizer(target: self, action: #selector(self.cell_TouchUpInside))
        addGestureRecognizer(tapGestureForPhoto)
        isUserInteractionEnabled = true
    }
    
    @objc func cell_TouchUpInside() {
        if let id = notification?.objectId {
            if notification!.type! == "follow" {
                delegate?.goToProfileVC(userId: id)
            } else if notification!.type! == "comment" {
                delegate?.goToCommentVC(postId: id)
            } else {
                delegate?.goToDetailVC(postId: id)
            }
        }
    }
    
    func setupUserInfo(){
        nameLabel.text = user?.username
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImg"))
        }
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
