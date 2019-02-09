//
//  SettingTableViewController.swift
//  Instagram
//
//  Created by Noy Ishai on 17/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

protocol SettingTableViewControllerDelegate{
    func updateUserInfor()
}

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var usernameTextFiled: UITextField!
    @IBOutlet weak var emailTextFiled: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var delegate:SettingTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Edit Profile"
        usernameTextFiled.delegate = self
        emailTextFiled.delegate = self
        fetchCurrentUser()
    }

    func fetchCurrentUser(){
        Api.User.observeCurrentUser {(user)in
            self.usernameTextFiled.text = user.username
            self.emailTextFiled.text = user.email
            if let profileUrl = URL(string: user.profileImageUrl!){
                self.profileImageView.sd_setImage(with: profileUrl)
            }
        }
    }
    //Press on the 'save' button will update the information
    @IBAction func saveBtn_TouchUp(_ sender: Any) {
        if let profileImg = self.profileImageView.image, let imageData = profileImg.jpegData(compressionQuality: 0.1){
            ProgressHUD.show("Waiting...")
            AuthService.updateUserInfor(username: usernameTextFiled.text!, email: emailTextFiled.text!, imageData: imageData, onSuccess: {
                //if we success to save daya we will show success and if there is an error we will show an error
                ProgressHUD.showSuccess("Success")
                self.delegate?.updateUserInfor()
            },onError: {(errorMessage) in
                    ProgressHUD.showError(errorMessage)
            })
 
        }
    }
    
    @IBAction func logoutBtn_TouchUp(_ sender: Any) {
        AuthService.logout(onSuccess: {
            let storyboard = UIStoryboard(name: "Start", bundle: nil)
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            self.present(signInVC, animated: true, completion: nil)
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
    //This button will allow user to pick photos
    @IBAction func changeProfileBtn_TouchUp(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
}

extension SettingTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

//return btn
extension SettingTableViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("return")
        textField.resignFirstResponder()
        return true
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
