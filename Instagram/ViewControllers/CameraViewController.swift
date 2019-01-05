//
//  CameraViewController.swift
//  Instagram
//
//  Created by admin on 18/12/2018.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    var selectedImage: UIImage?
    @IBOutlet weak var removeButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // photo gestrue + interuction (after clicking the photo place holder it sends you to phone gallery)
        let tapPhotoGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectPhoto))
        photo.addGestureRecognizer(tapPhotoGesture)
        photo.isUserInteractionEnabled = true
    }
    
    // Override to chain methods after viewDidApear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handlePost()
    }
    
    // Share button function
    @IBAction func shareButton_TouchUpInside(_ sender: Any) {
        // Makes the keyboard to close
        view.endEditing(true)
        // Using external library ProgressHUD to show the user the sign in progress
        ProgressHUD.show("Sharing...", interaction: false)
        if let profileImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 0.1){
            HelperService.uploadDataToServer(data: imageData, caption: captionTextView.text!) {
                self.clean()
                self.tabBarController?.selectedIndex = 0
            }
        } else {
            ProgressHUD.showError("Photo can't be empty")
        }
    }
    
    // Remove button function
    @IBAction func remove_TouchUpInside(_ sender: Any) {
        // Clearing the input after succeccful upload and returns to home view
        clean()
        handlePost()
    }
    
    // Enables/Disables the share button and changes it's color depands if photo selected
    func handlePost() {
        if self.selectedImage != nil {
            self.shareButton.isEnabled = true
            self.removeButton.isEnabled = true
            self.shareButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        } else {
            self.shareButton.isEnabled = false
            self.shareButton.isEnabled = false
            self.shareButton.backgroundColor = .lightGray
        }
    }
    
    // Makes the app tocuh sensitive everywhere on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Makes the keyboard to close
        view.endEditing(true)
    }
    
    // Photo selector
    func handleSelectPhoto() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    // Clean the photo and cation text
    func clean() {
        // Clearing the input after succeccful upload and returns to home view
        self.captionTextView.text = ""
        self.photo.image = UIImage(named: "placeholder-photo")
        self.selectedImage = nil
    }
}

// Sets the photo to be the selectedImage from the gallery
extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = image
            photo.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

