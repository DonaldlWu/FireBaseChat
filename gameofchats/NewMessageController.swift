//
//  NewMessageController.swift
//  gameofchats
//
//  Created by 吳得人 on 2017/5/9.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {

    let cellId = "cellId"
    
    var user = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        fetchUser()
    }
    
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary  = snapshot.value as? [String: AnyObject] {
                let user = User()
                
                // if you use this setter, your app will crash if your class properties don't exactly match up with firebase dictionary keys
                user.setValuesForKeys(dictionary)
                self.user.append(user)
                
                
                // this will crash because of background thread, so lets use dispatch_async to fix
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                //user.name = dictionary["name"]
                //print(user.name!, user.email!)
            }

        }, withCancel: nil)
    }
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // let use a hack for now, we actually need  to dequene or cells for memory efficiency

        // let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        
        // EP4 21:50
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let user = self.user[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        //cell.imageView?.image = UIImage(named: "tracer")
        
//        if let profileImageUrl = user.profileImageUrl {
//            let url = URL(string: profileImageUrl)
//            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
//                if error != nil {
//                    return
//                }
//                
//                DispatchQueue.main.async {
//                    cell.imageView?.image = UIImage(data: data!)
//                }
//                
//            }).resume()
//        }
        
        return cell
    }
    
}

class UserCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
