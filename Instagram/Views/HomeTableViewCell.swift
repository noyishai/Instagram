//
//  HomeTableViewCell.swift
//  Instagram
//
//  Created by Ronen on 03/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import KILabel

// Protocol for switching between view controllers
protocol HomeTableViewCellDelegate {
    func goToCommentVC(postId: String)
    func goToProfileUserVC(userId: String)
    func goToHashTag(tag: String)
}

class HomeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var captionLabel: KILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLabel: UILabel!
    
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
        // Makes Hashtags captions sensitive for clicking
        captionLabel.hashtagLinkTapHandler = { label, string, range in
            print(string)
            let tag = String(string.characters.dropFirst())
            self.delegate?.goToHashTag(tag: tag)
        }
        // Makes username mention clickable and delegate via protocol segue to their profile
        captionLabel.userHandleLinkTapHandler = { label, string, range in
            print(string)
            let mention = String(string.characters.dropFirst())
            print(mention)
            Api.User.observeUserByUsername(username: mention.lowercased(), completion: { (user) in
                self.delegate?.goToProfileUserVC(userId: user.id!)
            })
        }
        print("ratio: \(String(describing: post?.ratio))")
        //ratio = widthPhoto / heightPhoto
        //heightPhoto = widthPhoto / ratio
        
        //extract photo ratio
        if let ratio = post?.ratio{
            heightConstraint.constant = UIScreen.main.bounds.width / ratio
        }
        if let photoUrlString = post?.photoUrl {
            let photoUrl = URL(string: photoUrlString)
            // Uses SDWebimage to download the photo from the url
            postImageView.sd_setImage(with: photoUrl)
        }
        
        //unwarp and print the timestamp
        //Convert the timestamp
        if let timestamp = post?.timestamp{
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
                timeText = (diff.second == 1) ? "\(diff.second!) second ago" : "\(diff.second!) seconds ago"
            }
            if diff.minute! > 0 && diff.hour! == 0{
                timeText = (diff.minute == 1) ? "\(diff.minute!) minute ago" : "\(diff.second!) minutes ago"
            }
            
            if diff.hour! > 0 && diff.day! == 0{
                timeText = (diff.hour == 1) ? "\(diff.hour!) hour ago" : "\(diff.hour!) hours ago"
            }
            if diff.day! > 0 && diff.weekOfMonth! == 0{
                timeText = (diff.day == 1) ? "\(diff.day!) day ago" : "\(diff.day!) days ago"
            }
            if diff.weekOfMonth! > 0 {
                timeText = (diff.weekOfMonth == 1) ? "\(diff.weekOfMonth!) week ago" : "\(diff.weekOfMonth!) weeks ago"
            }
            
            timeLabel.text = timeText
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
        
        let tapGestureForNameLabel = UITapGestureRecognizer(target: self, action: #selector(self.nameLabel_TouchUpInside))
        nameLabel.addGestureRecognizer(tapGestureForNameLabel)
        nameLabel.isUserInteractionEnabled = true
        
    }
    
    // What to perform when comment pressed
    func commentImageView_TouchUpInside() {
        if let id = post?.id {
            delegate?.goToCommentVC(postId: id)
        }
    }
    
    // Clicking username label will segue to their profile
    func nameLabel_TouchUpInside(){
        if let id = user?.id {
            delegate?.goToProfileUserVC(userId: id)
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
