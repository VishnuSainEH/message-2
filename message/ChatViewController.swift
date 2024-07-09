//
//  ChatViewController.swift
//  message
//
//  Created by Apple 9 on 05/07/24.
//

import UIKit
import Firebase
import FirebaseAuth

private struct Constants {
    static let cellIdMessageReceived = "MessageCellView"
    static let cellIdMessageSent = "MessageCellMe"
}

class ChatViewController: UIViewController {
    
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintToBottom: NSLayoutConstraint!
    
    var roomId: String!
    var messages = [DataSnapshot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Chat"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.shared.fetchMessageFromServer(roomId: roomId) { snap in
            self.messages.append(snap)
            print(snap.value ?? "No value")
            self.tableView.reloadData()
            self.moveToLastMessage()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(showOrHideKeyboard(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showOrHideKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func showOrHideKeyboard(_ notification: NSNotification) {
        if let keyboardInfo = notification.userInfo {
            if notification.name == UIResponder.keyboardWillShowNotification {
                UIView.animate(withDuration: 1, animations: {
                    if let keyboardFrame = keyboardInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        self.constraintToBottom.constant = keyboardFrame.height
                        self.view.layoutIfNeeded()
                    }
                }) { (completed: Bool) -> Void in
                    self.moveToLastMessage()
                }
            } else if notification.name == UIResponder.keyboardWillHideNotification {
                UIView.animate(withDuration: 1, animations: {
                    self.constraintToBottom.constant = 0
                    self.view.layoutIfNeeded()
                }) { (completed: Bool) -> Void in
                    self.moveToLastMessage()
                }
            }
        }
    }
    
    func moveToLastMessage() {
        if self.tableView.contentSize.height > self.tableView.frame.height {
            let contentOffset = CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.height)
            self.tableView.setContentOffset(contentOffset, animated: true)
        }
    }
    
    @IBAction func sendButtonDidTapped(_ sender: AnyObject) {
        chatTextField.resignFirstResponder()
        if let text = chatTextField.text, !text.isEmpty {
            if let user = Auth.auth().currentUser {
                DataService.shared.createNewMessage(userId: user.uid, roomId: roomId, content: text)
            } else {
                print("No user is signed in")
            }
            chatTextField.text = nil
        } else {
            print("Error: Empty string")
        }
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageSnapshot = messages[indexPath.row]
        guard let message = messageSnapshot.value as? [String: AnyObject] else {
            return UITableViewCell()
        }
        let messageId = message["senderId"] as! String
        
        if messageId == Auth.auth().currentUser?.uid {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdMessageSent, for: indexPath) as! ChatTableViewCell
            cell.configCell(idUser: messageId, message: message)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdMessageReceived, for: indexPath) as! ChatTableViewCell
            cell.configCell(idUser: messageId, message: message)
            return cell
        }
    }
}
