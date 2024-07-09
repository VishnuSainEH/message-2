//
//  RoomCollectionViewController.swift
//  message
//
//  Created by Apple 7 on 01/07/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RoomCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // Firebase database reference
    let ROOM_REF = Database.database().reference().child("rooms")
    
    var rooms = [Room]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Observe child added events
        ROOM_REF.observe(.childAdded, with: { (snapshot) in
            if let roomData = snapshot.value as? [String: Any] {
                let room = Room(key: snapshot.key, snapshot: roomData)
                self.rooms.append(room)
                let indexPath = IndexPath(item: self.rooms.count - 1, section: 0)
                self.collectionView?.insertItems(at: [indexPath])
            }
        })

    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rooms.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "roomCell", for: indexPath) as! RoomCollectionViewCell
        let room = rooms[indexPath.row]
        cell.configureCell(room: room)
        return cell
    }

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 2 - 5, height: collectionView.frame.size.width / 2 - 5)
    }
    
    // MARK: User Actions
    
    @IBAction func logout(_ sender: AnyObject) {
        let actionSheetController = UIAlertController(title: "Please Select", message: "Option to select", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let profileActionButton = UIAlertAction(title: "Profile", style: .default) { action in
            let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "EditProfile") as! ProfileTableViewController
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
        actionSheetController.addAction(profileActionButton)
        
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive) { action in
            print("Log Out")
            self.logoutDidTapped()
        }
        actionSheetController.addAction(logoutAction)
        
        self.present(actionSheetController, animated: true, completion: nil)
    }

    func logoutDidTapped() {
        do {
            try Auth.auth().signOut()
            // Navigate to the login screen
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChatSegue" {
            if let cell = sender as? RoomCollectionViewCell,
               let indexPath = collectionView?.indexPath(for: cell) {
                let room = rooms[indexPath.item]
                let chatViewController = segue.destination as! ChatViewController
                chatViewController.roomId = room.id
            }
        }
    }
}
