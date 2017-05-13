//
//  ChatLogController.swift
//  gameofchats
//
//  Created by 吳得人 on 2017/5/13.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
        }
    }
    
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationItem.title = "Chat Log Controller"
        
        collectionView?.backgroundColor = UIColor.white
        
        setupInputComponents()
        
    }
    
    func setupInputComponents() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        // ios 9 constraint anchors
        // x, y, w, h
        
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        //x, y, w, h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
//        let inputTextField = UITextField()
//        inputTextField.placeholder = "Enter message..."
//        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(inputTextField)
        //x, y, w, h
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//        inputTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLoneView = UIView()
        separatorLoneView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLoneView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLoneView)
        //x, y, w, h
        separatorLoneView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLoneView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLoneView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLoneView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    func handleSend() {
        if inputTextField.text?.characters.count != 0 {
            let ref = FIRDatabase.database().reference().child("message")
            let childRef = ref.childByAutoId()
            let toId = user!.id!
            let fromId = FIRAuth.auth()!.currentUser!.uid
            let timestamp: NSNumber = (NSNumber(value: Int(NSDate().timeIntervalSince1970)))
            let value: [String : Any] = ["text": inputTextField.text!, "toId": toId, "fromId": fromId, "timestamp": timestamp]
//            childRef.updateChildValues(value)
            childRef.updateChildValues(value, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print(error!)
                    return
                }
                
                let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId)
                let messageId = childRef.key
                userMessagesRef.updateChildValues([messageId: 1])
                
                let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId)
                recipientUserMessagesRef.updateChildValues([messageId: 1])
                
            })
            
            print("Send Message to Firebase")
        } else {
            print("No message there")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
}
