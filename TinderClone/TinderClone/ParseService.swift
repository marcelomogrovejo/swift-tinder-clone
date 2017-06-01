//
//  ParseService.swift
//  TinderClone
//
//  Created by Marcelo Mogrovejo on 4/5/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import Foundation
import Parse

class ParseService {
    
    func initParse() {
        
        let parseConfig = ParseClientConfiguration { (ParseMutableClientConfiguration) -> Void in
            
//            ParseMutableClientConfiguration.applicationId = "1de6a95f2063b823bb036f77c2e3a17cfcad9166"
//            ParseMutableClientConfiguration.clientKey = "c9b8b52e4fb204797b20b55730c31af6224a64a8"
//            ParseMutableClientConfiguration.server = "http://ec2-52-10-43-179.us-west-2.compute.amazonaws.com:80/parse"

            ParseMutableClientConfiguration.applicationId = "SxR4snS3KxtkOOM3LURwbHNgoLQ04BDHx3mrfZMz"
            ParseMutableClientConfiguration.clientKey = "CHYGeuaLirIfj2NAqdThmmLHfX5V3HLnTg6BcyI2"
            ParseMutableClientConfiguration.server = "https://parseapi.back4app.com/"        }
        Parse.initialize(with: parseConfig)
        
    }
    
    func signUp(user: PFUser) -> () {
        
//      var onSuccess: Bool = false
//      var onError: NSError = NSError(domain: "", code: 1000, userInfo: nil)
        
        user.signUpInBackground(block: { (success, error) in

//            if error != nil {
//                //TODO: create alert or red message
//                //TODO: error handler
//                
//                onError = error! as NSError
//                
//            } else {
//                
//                // User added
//                onSuccess = success
//                
//            }
//            
//            return (onSuccess, onError)
            
        })

        
        
    }
    
}
