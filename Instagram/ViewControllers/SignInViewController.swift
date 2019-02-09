//
//  SignInViewController.swift
//  Instagram
//
//  Created by admin on 08/12/2018.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // emailTextField design
        emailTextField.backgroundColor = UIColor.clear
        emailTextField.tintColor = UIColor.white
        emailTextField.textColor = UIColor.white
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor(white: 1.0, alpha: 0.6)]))
        let bottomLayerEmail = CALayer()
        bottomLayerEmail.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        bottomLayerEmail.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        emailTextField.layer.addSublayer(bottomLayerEmail)
        
        // passwordTextField design
        passwordTextField.backgroundColor = UIColor.clear
        passwordTextField.tintColor = UIColor.white
        passwordTextField.textColor = UIColor.white
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor(white: 1.0, alpha: 0.6)]))
        let bottomLayerPassword = CALayer()
        bottomLayerPassword.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        bottomLayerPassword.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        passwordTextField.layer.addSublayer(bottomLayerPassword)
        
        signInButton.isEnabled = false
        
        // Observer to see if user input did change
        handleTextField()
    }
    
    // Makes the app tocuh sensitive everywhere on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Makes the keyboard to close
        view.endEditing(true)
    }
    
    // Override viewDidApear to make sure viewDidApear will load first, then the automatic login will perform
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Automaticly login the user if the credentials already exists
        if Api.User.CURRENT_USER != nil {
            self.performSegue(withIdentifier: "SignInToTabBarVC", sender: nil)
        }
    }
    
    // Observer to see if user input did change
    func handleTextField() {
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    // Checking if the user inputs are not empty and if not changing the Sign In botton color and enables is
    @objc func textFieldDidChange() {
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
            signInButton.setTitleColor(UIColor.lightText, for: UIControl.State.normal)
            signInButton.isEnabled = false
            return
        }
        signInButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        signInButton.isEnabled = true
    }
    
    // Sign In button calls the signIn from Firebase to login using user inputs
    @IBAction func signInButton_TouchUpInside(_ sender: Any) {
        // Makes the keyboard to close
        view.endEditing(true)
        
        // Using external library ProgressHUD to show the user the sign in progress
        ProgressHUD.show("SignIn in progress", interaction: false)
        
        AuthService.signIn(email: emailTextField.text!, password: passwordTextField.text!, onSuccess: {
            // Using external library ProgressHUD to show the user the if the sign in succeeded
            ProgressHUD.showSuccess("SignIn Success")
            self.performSegue(withIdentifier: "SignInToTabBarVC", sender: nil)
        }, onError: { error in
            // Using external library ProgressHUD to show the user the error returned from Firebase
            ProgressHUD.showError(error!)
        })
    }
    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
