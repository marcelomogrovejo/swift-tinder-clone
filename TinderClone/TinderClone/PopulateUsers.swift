//
//  PopulateUsers.swift
//  TinderClone
//
//  Created by Marcelo Mogrovejo on 5/5/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import Foundation
import Parse

class PopulateUsers {
    
    let femaleImageUrlArray: [String] = [
        "https://itfinspiringwomen.files.wordpress.com/2014/03/scooby-doo-tv-09.jpg",
        "https://thanksdaria.files.wordpress.com/2013/05/angelica.jpg",
        "http://editorial.designtaxi.com/news-pregnantcartoons060514/3.jpg",
        "https://s-media-cache-ak0.pinimg.com/originals/93/a2/45/93a245b1bd1c088cc497b7c93a78e7a1.jpg",
        "https://s-media-cache-ak0.pinimg.com/originals/9c/5e/86/9c5e86be6bf91c9dea7bac0ab473baa4.jpg",
        "https://www.divahair.ro/images/speciale/articole/articole_imagini/alexag_135/01.04.2014/jasmine.jpg"
    ]
    
    let maleImageUrlArray: [String] = [
        "http://esq.h-cdn.co/assets/cm/15/06/480x269/54d1ad60d8821_-_esq-cartoons-fred.jpg",
        "https://s-media-cache-ak0.pinimg.com/originals/7e/e2/af/7ee2af286de01181330f3fdaf1ec296a.jpg",
        "https://s-media-cache-ak0.pinimg.com/originals/52/f5/04/52f5047ae0256589e9f8d56509d233c1.jpg",
        "http://www.cartoondistrict.com/wp-content/uploads/2014/08/Funny-pictures-of-fat-cartoons2.jpg"
    ]
    
    var i: Int = 0
    
    func createUsers() {
        
        // Male
        for index in 0 ..< maleImageUrlArray.count {
            downloadImage(urlString: maleImageUrlArray[index], isFemale: false)
        }
        
        // Female
        for index in 0 ..< femaleImageUrlArray.count {
            downloadImage(urlString: femaleImageUrlArray[index], isFemale: true)
        }

    }
    
    func downloadImage(urlString: String, isFemale: Bool) {
        
//        print("Downloading image...")
        
        getImageDataFomUrl(sourceUrl: urlString) { (data, response, error) in
            
            guard let data = data, error == nil else { return }
//            print("Download finished.")
            
            self.i += 1
            
            print("User\(self.i)")

            let user = PFUser()
            user["username"] = "User\(self.i)"
            user["password"] = "12345678"
            user["isFemale"] = isFemale
            user["isInterestedInWomen"] = !isFemale
            user["photo"] = PFFile(name: "profile.png", data: data)

            user.signUpInBackground(block: { (success, error) in
                
                if error != nil {
                    let err = error! as NSError
                    print(err.userInfo["error"]!)
                } else {
                    print("User was added successfully")
                }
                
            })
        }
    }
    
    func getImageDataFomUrl(sourceUrl: String, completion: @escaping(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {

        let url = URL(string: sourceUrl)
        let request  = URLRequest(url: url!)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in

            completion(data, response, error)
            
        })
        task.resume()
    }
    
}
