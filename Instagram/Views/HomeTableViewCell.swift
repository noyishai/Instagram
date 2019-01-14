//
//  HomeTableViewCell.swift
//  Instagram
//
//  Created by Ronen on 03/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
protocol  HomeTableViewCellDelegate {
    func goToCommentVC(postId: String)

}

class HomeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    
    var delegate: HomeTableViewCellDelegate?
    // Ovserver which wait to see if the post instance variable is set
    var post: Post? {
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
    
    // Updates the cells with posts data
    func updateView() {
        captionLabel.text = post?.caption
        if let photoUrlString = post?.photoUrl {
            let photoUrl = URL(string: photoUrlString)
            // Uses SDWebimage to download the photo from the url
            postImageView.sd_setImage(with: photoUrl)
        }
        
        // Observe for single change to update the posts while scrolling down so we wont have the image move between posts
       
            self.updateLike(post: self.post!)
       
        
        // Observe for childChanged, in this case for the likesCount to change by other users
        
    }
    
    // Checks if the post liked or not and change the like image accordingly + increase/decrease the likesCount
    
    func updateLike(post: Post) {
        let imageName = post.likes == nil || !post.isLiked! ? "like" : "likeSelected"
        likeImageView.image = UIImage(named: imageName)
        // Checks if someoene liked the post and changes the title benif
        guard let count = post.likeCount else{
            return
            
        }
        if count != 0 {
            likeCountButton.setTitle("\(count) Likes", for: UIControlState.normal)
        } else {
            likeCountButton.setTitle("Like First", for: UIControlState.normal)
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
            delegate?.goToCommentVC(postId: id)
        }
    }
    
    // What to perform when like pressed
    func likeImageView_TouchUpInside() {
        Api.Post.incrementLikes(postId:post!.id!, onSuccess: { (post: Post) in
            self.updateLike(post: post)
            self.post?.likes = post.likes
            self.post?.isLiked = post.isLiked
            self.post?.likeCount = post.likeCount
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
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
