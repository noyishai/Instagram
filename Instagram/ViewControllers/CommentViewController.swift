//
//  CommentViewController.swift
//  Instagram
//
//  Created by Ronen on 03/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController {
    
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintToBottom: NSLayoutConstraint!
    
    var comments = [Comment]()
    var users = [UserModel]()
    
    var postId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Comment"
        tableView.dataSource = self
        // Lets the tableView estimight it's height for better performance
        tableView.estimatedRowHeight = 77
        // Lets the cells to automatic adjust it's size based on it's content
        tableView.rowHeight = UITableViewAutomaticDimension
        empty()
        sendButton.isEnabled = false
        handleTextField()
        loadComments()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // What to do when the view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true // Hides the tabBar
    }
    
    // What to do when the view disappears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false // Enables the tabBar
    }
    
    @IBAction func sendButton_TouchUpInside(_ sender: Any) {
        let commentsReference = Api.Comment.REF_COMMENTS
        // Creates new random ID for each post
        let newCommentId = commentsReference.childByAutoId().key
        let newCommentReference = commentsReference.child(newCommentId!)
        guard let currentUser = Api.User.CURRENT_USER else {
            return
        }
        let currentUserId = currentUser.uid
        newCommentReference.setValue(["uid": currentUserId, "commentText": commentTextField.text!], withCompletionBlock: { (error, ref) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            // Creats "words" array and seperate them into "word" to look for HashTags (#)
            let words = self.commentTextField.text!.components(separatedBy: CharacterSet.whitespacesAndNewlines)
            
            for var word in words {
                if word.hasPrefix("#") {
                    word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters) // Removes special characters so we wont crash
                    let newHashTagRef = Api.HashTag.REF_HASHTAG.child("hashTag")
                    newHashTagRef.updateChildValues([self.postId: true])
                }
            }
            
            let postCommentRef = Api.Post_Comment.REF_POSTS_COMMENTS.child(self.postId).child(newCommentId!)
            postCommentRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            })
            self.empty()
            self.view.endEditing(true)
        })
    }
    
    // Makes the app tocuh sensitive everywhere on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Makes the keyboard to close
        view.endEditing(true)
        print("test")
    }
    
    func keyboardWillShow(_ notification: NSNotification){
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        UIView.animate(withDuration: 0.3) {
            self.constraintToBottom.constant = -(keyboardFrame!.height)
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(_ notification: NSNotification){
        UIView.animate(withDuration: 0.3) {
            self.constraintToBottom.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    // Getting comments and observe for new ones realtime
    func loadComments() {
            Api.Post_Comment.REF_POSTS_COMMENTS.child(self.postId).observe(.childAdded) { (snapshot) in
            // Retriving comments data from Firebase Database
            Api.Comment.observeComments(withPostId: snapshot.key, completion: { (comment: Comment) in
                self.fetchUser(uid: comment.uid!, completed: {
                    self.comments.append(comment)
                    self.tableView.reloadData()
                })
            })
        }
    }
    
    // Given user ID gives the data
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        Api.User.observeUser(withId: uid) { (user: UserModel) in
            self.users.append(user)
            completed()
        }
    }
    
    // Clearing the comment section
    func empty() {
        self.commentTextField.text = ""
        sendButton.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
        sendButton.isEnabled = false
    }
    
    // Segues of the protocol
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Comment_ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }
        
        if segue.identifier == "Comment_HashTagSegue" {
            let hashTagVC = segue.destination as! HashTagViewController
            let tag = sender as! String
            hashTagVC.tag = tag
        }
    }
    
    // Observer to see if user input did change
    func handleTextField() {
        commentTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    // Checking if the userinputs are not empty and if not changing the Sign Up botton color and enables is
    func textFieldDidChange() {
        // If the comment field has text, enable the button
        if let commentText = commentTextField.text, !commentText.isEmpty {
            sendButton.setTitleColor(UIColor.black, for: UIControlState.normal)
            sendButton.isEnabled = true
            return
        }
        // If the comment field has no text, disable the button
        sendButton.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
        sendButton.isEnabled = false
    }
    
}

extension CommentViewController: UITableViewDataSource {
    // Sets the number of tableView rows to be the number of comments stored in the Firebase Database
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    // Defines how each cell of the tableView should look like
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        let comment = comments[indexPath.row]
        let user = users[indexPath.row]
        cell.comment = comment
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension CommentViewController: CommentTableViewCellDelegate {
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Comment_ProfileSegue", sender: userId)
    }
    
    func goToHashTag(tag: String) {
        performSegue(withIdentifier: "Comment_HashTagSegue", sender: tag)
    }
}
