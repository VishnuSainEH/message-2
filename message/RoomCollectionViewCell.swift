//
//  RoomCollectionViewCell.swift
//  message
//
//  Created by Apple 9 on 06/07/24.
//

import UIKit
import Firebase
import FirebaseStorage

class RoomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailPhoto: UIImageView!
    @IBOutlet weak var captionLbl: UILabel!
    
    func configureCell(room: Room) {
        self.captionLbl.text = room.caption
        
        if let imageUrl = room.thumbnail {
            if imageUrl.hasPrefix("gs://") {
                Storage.storage().reference(forURL: imageUrl).getData(maxSize: INT64_MAX) { (data, error) in
                    if let error = error {
                        print("Error downloading: \(error)")
                        return
                    }
                    if let data = data {
                        self.thumbnailPhoto.image = UIImage(data: data)
                    }
                }
            } else if let url = URL(string: imageUrl), let data = try? Data(contentsOf: url) {
                self.thumbnailPhoto.image = UIImage(data: data)
            }
        }
    }
}

