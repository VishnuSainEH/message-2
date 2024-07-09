//
//  Room.swift
//  message
//
//  Created by Apple 9 on 06/07/24.
//

import Foundation

class Room {
    var caption: String!
    var thumbnail: String!
    var id: String!
    
    init(key: String, snapshot: [String: Any]) {
        self.id = key
        self.caption = snapshot["caption"] as? String ?? ""
        self.thumbnail = snapshot["thumbnailUrlFromStorage"] as? String ?? ""
    }
}
