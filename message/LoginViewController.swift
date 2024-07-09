//
//  LoginViewController.swift
//  message
//
//  Created by Apple 7 on 01/07/24.
//

import UIKit
import FirebaseAuth
import ProgressHUD
class LoginViewController: UIViewController {

    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        view.addGestureRecognizer(dismissKeyboard)
    }
    
    @objc func dismissKeyboard(_ tap: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func logInDidTapped(_ sender: Any) {
        guard let email = emailTxtField.text, !email.isEmpty,
              let password = passwordTxtField.text, !password.isEmpty else {
            ProgressHUD.animate("Email/Password can't be empty")
            return
        }
        
        ProgressHUD.animate("Signing in..")
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                ProgressHUD.animate("Login failed: \(error.localizedDescription)")
                return
            }
            
            ProgressHUD.succeed("Logged in successfully!")
            
            // Navigate to another view controller or perform necessary actions upon successful login
            // For example:
            // self.performSegue(withIdentifier: "LoggedInSegue", sender: nil)
        }
    }
}
