//
//  ProfileTableViewController.swift
//  message
//
//  Created by Apple 7 on 01/07/24.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import ProgressHUD

class ProfileTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "EDIT PROFILE"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectPhoto(_:)))
        tap.numberOfTapsRequired = 1
        profileImage.addGestureRecognizer(tap)
        profileImage.isUserInteractionEnabled = true
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.clipsToBounds = true

        if let user = Auth.auth().currentUser {
            username.text = user.displayName
            email.text = user.email
            if let photoURL = user.photoURL {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: photoURL) {
                        DispatchQueue.main.async {
                            self.profileImage.image = UIImage(data: data)
                        }
                    }
                }
            }
        }
    }

    @objc func selectPhoto(_ tap: UITapGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        self.present(imagePicker, animated: true, completion: nil)
    }

    // Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            profileImage.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImage.image = originalImage
        }
        picker.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveDidTapped(_ sender: AnyObject) {
        guard let image = profileImage.image, let imageData = image.jpegData(compressionQuality: 0.1) else {
            print("Profile image is missing.")
            return
        }
        
        guard let username = username.text, !username.isEmpty, let email = email.text, !email.isEmpty else {
            print("Username or email is missing.")
            return
        }

        ProgressHUD.animate("Please wait...", interaction: false)
        
        let storageRef = Storage.storage().reference().child("profile_images").child("\(Auth.auth().currentUser?.uid ?? "user").jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Failed to upload profile image:", error)
                ProgressHUD.bannerHide()
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL:", error)
                    ProgressHUD.bannerHide()
                    return
                }
                
                guard let photoURL = url else {
                    ProgressHUD.bannerHide()
                    return
                }

                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username
                changeRequest?.photoURL = photoURL
                changeRequest?.commitChanges { error in
                    if let error = error {
                        print("Failed to update profile:", error)
                    } else {
                        print("Profile updated successfully")
                    }
                    ProgressHUD.bannerHide()
                }
            }
        }
    }
}
