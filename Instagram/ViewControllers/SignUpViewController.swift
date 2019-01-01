//
//  SignUpViewController.swift
//  Instagram
//
//  Created by admin on 08/12/2018.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // username text field design
        usernameTextField.backgroundColor = UIColor.clear
        usernameTextField.tintColor = UIColor.white
        usernameTextField.textColor = UIColor.white
        usernameTextField.attributedPlaceholder = NSAttributedString(string: usernameTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.6)])
        let bottomLayerUsername = CALayer()
        bottomLayerUsername.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        bottomLayerUsername.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        usernameTextField.layer.addSublayer(bottomLayerUsername)
        
        // email text field design
        emailTextField.backgroundColor = UIColor.clear
        emailTextField.tintColor = UIColor.white
        emailTextField.textColor = UIColor.white
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.6)])
        let bottomLayerEmail = CALayer()
        bottomLayerEmail.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        bottomLayerEmail.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        emailTextField.layer.addSublayer(bottomLayerEmail)
        
        // password text field design
        passwordTextField.backgroundColor = UIColor.clear
        passwordTextField.tintColor = UIColor.white
        passwordTextField.textColor = UIColor.white
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.6)])
        let bottomLayerPassword = CALayer()
        bottomLayerPassword.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        bottomLayerPassword.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        passwordTextField.layer.addSublayer(bottomLayerPassword)
        
        // profile image design
        profileImage.layer.cornerRadius = 40
        profileImage.clipsToBounds = true
        
        // profile image gestrue + interuction (after clicking the profile image it sends you to phone gallery)
        let tapProfileImageGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.handleSelectProfileImageView))
        profileImage.addGestureRecognizer(tapProfileImageGesture)
        profileImage.isUserInteractionEnabled = true
        
        // Observer to see if user input did change
        handleTextField()
    }
    
    // Observer to see if user input did change
    func handleTextField() {
        usernameTextField.addTarget(self, action: #selector(SignUpViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
        emailTextField.addTarget(self, action: #selector(SignUpViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(SignUpViewController.textFieldDidChange), for: UIControlEvents.editingChanged)

    }
    
    // Checking if the userinputs are not empty and if not changing the Sign Up botton color and enables is
    func textFieldDidChange() {
        guard let username = usernameTextField.text, !username.isEmpty, let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
            signUpButton.setTitleColor(UIColor.lightText, for: UIControlState.normal)
            signUpButton.isEnabled = false
            return
        }
        signUpButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        signUpButton.isEnabled = true
    }
    
    // Profile image selector
    func handleSelectProfileImageView() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func dismiss_onClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Signup botton calls the createUser from Firebase to create a user
    @IBAction func signUpBtn_TouchUpInside(_ sender: Any) {
        // need to move to FIrebase Model
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authDataResult:AuthDataResult?, error:Error?) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            let uid = authDataResult?.user.uid
            let storageRef = Storage.storage().reference(forURL: "gs://instagram-a9572.appspot.com").child("profile_image").child(uid!)
            if let profileImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 0.1){
                storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        return // error
                    }
                    storageRef.downloadURL( completion: { (url, error) in
                        if error != nil {
                            return // error
                        }
                        guard let profileImageUrl = url?.absoluteString else { return }
                        self.setUserInformation(profileImageUrl: profileImageUrl, username: self.usernameTextField.text!, email: self.emailTextField.text!, uid: uid!)
                    })
                })
            }
        }
    }
    
    // Sets the user information
    func setUserInformation(profileImageUrl: String, username: String, email: String, uid: String){
            let ref = Database.database().reference()
            let usersReference = ref.child("users")
            let newUserReference = usersReference.child(uid)
            newUserReference.setValue(["username": username, "email": email, "profileImageUrl": profileImageUrl])
    }
}

// Setting the profileImage to be the selectedImage from the gallery
extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = image
            profileImage.image = image
        }
        dismiss(animated: true, completion: nil)
        
    }
}

