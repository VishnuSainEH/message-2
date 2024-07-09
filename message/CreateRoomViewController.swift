//
//  CreateRoomViewController.swift
//  message
//
//  Created by Apple 7 on 01/07/24.
//

import UIKit
import FirebaseAuth

class CreateRoomViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var choosePhotoBtn: UIButton!
    @IBOutlet weak var photoImg: UIImageView!
    @IBOutlet weak var captionLbl: UITextField!

    var selectedPhoto: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        dismissKeyboard.numberOfTapsRequired = 1
        view.addGestureRecognizer(dismissKeyboard)
    }

    @objc func dismissKeyboard(_ tap: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @IBAction func cancelDidTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func selectPhotoDidTapped(_ sender: AnyObject) {
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

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        selectedPhoto = info[.originalImage] as? UIImage
        photoImg.image = selectedPhoto
        picker.dismiss(animated: true, completion: nil)
        choosePhotoBtn.isHidden = true
    }

    @IBAction func createRoomDidTapped(_ sender: Any) {
        guard let imageData = photoImg.image?.jpegData(compressionQuality: 0.1), let caption = captionLbl.text, !caption.isEmpty else {
            print("All fields are required.")
            return
        }
        
        if let currentUser = Auth.auth().currentUser {
            DataService.shared.createNewRoom(user: currentUser, caption: caption, data: imageData)
        } else {
            print("User is not logged in.")
        }
    }
}
