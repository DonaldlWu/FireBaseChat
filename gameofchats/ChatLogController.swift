//
//  ChatLogController.swift
//  gameofchats
//
//  Created by 吳得人 on 2017/5/13.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            observeMessage()
        }
    }
    
    var messages = [Message]()
    
    func observeMessage() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("message").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                //print(snapshot)
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let message = Message()
                // potential of crashing if keys don't match
                message.setValuesForKeys(dictionary)
                
                if message.chatPartnerId() == self.user?.id {
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
                
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 58, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        
        setupInputComponents()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        moveChatBubbleTobottom()
    }
    
    func moveChatBubbleTobottom() {
        let startFromBottom = CGPoint(x: 0, y: (collectionView?.contentSize.height)! - (collectionView?.frame.size.height)! + 32)
        if (collectionView?.contentSize.height)! + 58 > (collectionView?.frame.size.height)! {
            collectionView?.setContentOffset(startFromBottom, animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        //let modify the bubbleView width
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 32
        
        return cell
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        // get estimated height
        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text: text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func setupInputComponents() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
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
                
                self.inputTextField.text = nil
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
