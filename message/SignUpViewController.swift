//
//  SignUpViewController.swift
//  message
//
//  Created by Apple 7 on 01/07/24.
//

import UIKit
import ProgressHUD
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let imagePicker = UIImagePickerController()
    var selectedPhoto: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(selectPhoto(_:)))
        tap.numberOfTapsRequired = 1
        profileImage.addGestureRecognizer(tap)
        profileImage.isUserInteractionEnabled = true

        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.clipsToBounds = true

        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }

    @objc func selectPhoto(_ tap: UITapGestureRecognizer) {
        imagePicker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func cancelDidTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func signUpDidTapped(_ sender: AnyObject) {
        // Sign up logic here
        guard
            let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty,
            let username = usernameTextField.text, !username.isEmpty,
            let profileImage = profileImage.image else {
                print("All fields are required.")
                return
        }
        
        guard let imageData = profileImage.jpegData(compressionQuality: 0.1) else {
            print("Error converting image to data.")
            return
        }
        ProgressHUD.animate("Please wait ...", interaction: false)
        DataService.shared.signUp(username: username, email: email, password: password, data: imageData)
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        selectedPhoto = info[.originalImage] as? UIImage
        profileImage.image = selectedPhoto
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
