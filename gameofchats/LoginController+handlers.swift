//
//  LoginController+handlers.swift
//  gameofchats
//
//  Created by 吳得人 on 2017/5/9.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import UIKit
import Firebase

extension loginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
     
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
    func handleRegister(){
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text
            else {
                print("Form is not valid")
                return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion:
            { (user: FIRUser?, error) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                guard let uid = user?.uid else {
                    return
                }
                // Successfully authenticated user and save data
                let imageName = NSUUID().uuidString
                let storageRef = FIRStorage.storage().reference().child("profile_image").child("\(imageName).png")
                
                if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) {
                    storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                        
                        if error != nil {
                            print(error!)
                            return
                        }
                        if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                            let value = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                            self.registerUserIntoDatabase(uid: uid, value: value as [String : AnyObject])
                            print(metadata!)
                        }
                    })
                }
            })
    }
    
    private func registerUserIntoDatabase(uid: String, value: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference(fromURL: "https://gameofchats-28ae8.firebaseio.com/")
        let userReference = ref.child("users").child(uid)
        userReference.updateChildValues(value, withCompletionBlock: { (err, ref)
            in
            if err != nil {
                print(err!)
            }
            self.dismiss(animated: true, completion: nil)
        })
    
    }
    
}
