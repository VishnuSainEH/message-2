//
//  DataService.swift
//  message
//
//  Created by Apple 9 on 04/07/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import ProgressHUD

let roofRef = Database.database().reference()

class DataService {
    static let shared = DataService()
    
    private var _BASE_REF = roofRef
    private var _ROOM_REF = roofRef.child("room")
    private var _MESSAGE_REF = roofRef.child("messages")
    private var _PEOPLE_REF = roofRef.child("people")
    
    var currentUser: User? {
        return Auth.auth().currentUser
    }
    
    var BASE_REF: DatabaseReference {
        return _BASE_REF
    }
    var ROOM_REF: DatabaseReference {
        return _ROOM_REF
    }
    var MESSAGE_REF: DatabaseReference {
        return _MESSAGE_REF
    }
    var PEOPLE_REF: DatabaseReference {
        return _PEOPLE_REF
    }
    var storageRef: StorageReference {
        return Storage.storage().reference()
    }
    
    var fileUrl: String?
    
    func createNewRoom(user: User, caption: String, data: Data) {
        let filepath = "\(user.uid)/\(Int(Date().timeIntervalSince1970))"
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        storageRef.child(filepath).putData(data, metadata: metaData) { (metadata, error) in
            if let error = error {
                print("Error uploading: \(error.localizedDescription)")
                return
            }
            self.storageRef.child(filepath).downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error)")
                    return
                }
                self.fileUrl = url?.absoluteString
                if let user = Auth.auth().currentUser {
                    let idRoom = self.BASE_REF.child("rooms").childByAutoId()
                    idRoom.setValue(["caption": caption, "thumbnailUrlFromStorage": self.storageRef.child(filepath).description, "fileUrl": self.fileUrl!])
                }
            }
        }
    }

    func fetchDataServer(callback: @escaping (Room) -> ()) {
        DataService.shared.ROOM_REF.observe(.childAdded) { (snapshot) in
            let room = Room(key: snapshot.key, snapshot: snapshot.value as! [String: AnyObject])
            callback(room)
        }
    }

    func signUp(username: String, email: String, password: String, data: Data) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let user = result?.user else { return }
            
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = username
            changeRequest.commitChanges { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
            
            let filePath = "ProfileImage/\(user.uid)"
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            self.storageRef.child(filePath).putData(data, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                self.storageRef.child(filePath).downloadURL { (url, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    guard let downloadURL = url?.absoluteString else { return }
                    self.fileUrl = downloadURL
                    
                    let changeRequestPhoto = user.createProfileChangeRequest()
                    changeRequestPhoto.photoURL = URL(string: self.fileUrl!)
                    changeRequestPhoto.commitChanges { (error) in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        } else {
                            print("Profile updated")
                        }
                    }
                }
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            }
        }
    }
    
    func logIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let user = result?.user else { return }
            
            self.PEOPLE_REF.child(user.uid).setValue(["username": user.displayName ?? "", "email": email, "profileImage": user.photoURL?.absoluteString ?? ""])
            ProgressHUD.succeed("Succeeded")
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.login()
        }
    }

    func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let logInVC = storyboard.instantiateViewController(withIdentifier: "LogInVC")
            UIApplication.shared.keyWindow?.rootViewController = logInVC
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
    func saveProfile(username: String, email: String, data: Data) {
        guard let user = Auth.auth().currentUser else { return }
        
        let filepath = "\(user.uid)/\(Int(Date().timeIntervalSince1970))"
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        self.storageRef.child(filepath).putData(data, metadata: metaData) { (metadata, error) in
            if let error = error {
                print("Error uploading: \(error.localizedDescription)")
                return
            }
            
            self.storageRef.child(filepath).downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error)")
                    return
                }
                
                self.fileUrl = url?.absoluteString
                
                let changeRequestPhoto = user.createProfileChangeRequest()
                changeRequestPhoto.photoURL = URL(string: self.fileUrl!)
                changeRequestPhoto.displayName = username
                changeRequestPhoto.commitChanges { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                        ProgressHUD.animate("Network Error")
                        return
                    } else {
                        print("Profile updated")
                    }
                }
            }
        }
        
        user.updateEmail(to: email) { (error) in
            if let error = error {
                print("Email update failed: \(error.localizedDescription)")
                return
            } else {
                print("Email updated successfully")
            }
        }
        
        self.PEOPLE_REF.child(user.uid).setValue(["username": username, "email": email, "profileImage": self.fileUrl ?? ""])
        ProgressHUD.success("Saved")
    }
    
    func createNewMessage(userId: String, roomId: String, content: String) {
        let idMessage = roofRef.child("messages").childByAutoId()
        DataService.shared.MESSAGE_REF.child(idMessage.key!).setValue(["message": content, "senderId": userId])
        DataService.shared.ROOM_REF.child(roomId).child("messages").child(idMessage.key!).setValue(true)
    }
    
    func fetchMessageFromServer(roomId: String, callback: @escaping (DataSnapshot) -> ()) {
        DataService.shared.ROOM_REF.child(roomId).child("messages").observe(.childAdded) { snapshot in
            DataService.shared.MESSAGE_REF.child(snapshot.key).observe(.value) { snap in
                callback(snap)
            }
        }
    }
}
