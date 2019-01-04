//
//  HomeTableViewCell.swift
//  Instagram
//
//  Created by Ronen on 03/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class HomeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    
    var homeVC: HomeViewController?
    
    // Ovserver which wait to see if the post instance variable is set
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    // Ovserver which wait to see if the user instance variable is set
    var user: User? {
        didSet {
            setupUserInfo()
        }
    }
    
    // Updates the cells with posts data
    func updateView() {
        captionLabel.text = post?.caption
        if let photoUrlString = post?.photoUrl {
            let photoUrl = URL(string: photoUrlString)
            // Uses SDWebimage to download the photo from the url
            postImageView.sd_setImage(with: photoUrl)
        }
        
        // Checks if the user liked the post
        if let currentUser = Auth.auth().currentUser {
            Api.User.REF_USERS.child(currentUser.uid).child("likes").child(post!.id!).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
                if let _ = snapshot.value as? NSNull {
                    self.likeImageView.image = UIImage(named: "like")
                } else {
                    self.likeImageView.image = UIImage(named: "likeSelected")
                }
            }
        }
    }
    
    // Gets the user data
    func setupUserInfo() {
        nameLabel.text = user?.username
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImageView.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImg"))
        }
    }
    
    // What to do with the cells when loaded to memory and didnt downloaded items from database
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.text = ""
        captionLabel.text = ""
        // Gesture to specify what to do when you press comment
        let tapCommentGesture = UITapGestureRecognizer(target: self, action: #selector(self.commentImageView_TouchUpInside))
        commentImageView.addGestureRecognizer(tapCommentGesture)
        commentImageView.isUserInteractionEnabled = true
        
        // Gesture to specify what to do when you press like
        let tapLikeGesture = UITapGestureRecognizer(target: self, action: #selector(self.likeImageView_TouchUpInside))
        likeImageView.addGestureRecognizer(tapLikeGesture)
        likeImageView.isUserInteractionEnabled = true
        

    }
    
    // What to perform when comment pressed
    func commentImageView_TouchUpInside() {
        if let id = post?.id {
            homeVC?.performSegue(withIdentifier: "CommentSegue", sender: id)

        }
    }
    
    // What to perform when like pressed
    func likeImageView_TouchUpInside() {
        // Checks if the user liked the post
        if let currentUser = Auth.auth().currentUser {
            Api.User.REF_USERS.child(currentUser.uid).child("likes").child(post!.id!).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
                if let _ = snapshot.value as? NSNull {
                    Api.User.REF_USERS.child(currentUser.uid).child("likes").child(self.post!.id!).setValue(true)
                    self.likeImageView.image = UIImage(named: "likeSelected")
                } else {
                    Api.User.REF_USERS.child(currentUser.uid).child("likes").child(self.post!.id!).removeValue()
                    self.likeImageView.image = UIImage(named: "like")
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print("Reusing cell")
        profileImageView.image = UIImage(named: "placeholderImg")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
