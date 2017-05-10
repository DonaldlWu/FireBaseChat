//
//  Extension.swift
//  gameofchats
//
//  Created by 吳得人 on 2017/5/11.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCasheWithUrlString(urlString: String) {
      
        // flash image because reuse cell
        
        self.image = nil
        
        //check cache fot image first 
        
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            
            self.image = cachedImage
            
            return
        }
        
        //otherwise fire off new download
        
        let url = URL(string: urlString)
        
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                return
            }
            
            DispatchQueue.main.async {
                
                if let downloadedImage  = UIImage(data: data!) {
                
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    
                    self.image = UIImage(data: data!)
                    
                }
                
            }
            
        }).resume()
    }
    
}
