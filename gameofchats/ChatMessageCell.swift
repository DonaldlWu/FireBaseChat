//
//  ChatMessageCell.swift
//  gameofchats
//
//  Created by 吳得人 on 2017/5/14.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "SAMPLE TEXT HERE"
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 16)
        return tv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textView)
        
        // ios 9 constraints
        // x, y, w, h
        
        textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
