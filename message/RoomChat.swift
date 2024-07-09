//
//  RoomChat.swift
//  message
//
//  Created by Apple 9 on 08/07/24.
//
import UIKit
import Firebase
import FirebaseStorage

class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
    }
    
    func configCell(idUser: String, message: [String: AnyObject]) {
        self.messageTextLabel.text = message["message"] as? String
        
        DataService.shared.PEOPLE_REF.child(idUser).observe(.value, with: { snapshot in
            guard let dict = snapshot.value as? [String: AnyObject] else { return }
            if let imageUrl = dict["profileImage"] as? String {
                if imageUrl.hasPrefix("gs://") {
                    Storage.storage().reference(forURL: imageUrl).getData(maxSize: INT64_MAX) { data, error in
                        if let error = error {
                            print("Error downloading: \(error)")
                            return
                        }
                        if let data = data {
                            self.profileImageView.image = UIImage(data: data)
                        }
                    }
                } else {
                    if let url = URL(string: imageUrl) {
                        URLSession.shared.dataTask(with: url) { data, response, error in
                            if let error = error {
                                print("Error downloading: \(error)")
                                return
                            }
                            if let data = data {
                                DispatchQueue.main.async {
                                    self.profileImageView.image = UIImage(data: data)
                                }
                            }
                        }.resume()
                    }
                }
            }
        })
    }
}
