//
//  Message.swift
//  gameofchats
//
//  Created by 吳得人 on 2017/5/13.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {

    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    func chatPartnerId() -> String? {
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
}
