//
//  Util.swift
//  TinderClone
//
//  Created by Marcelo Mogrovejo on 5/18/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import UIKit

class Util {
    
    let opaqueBackgroundView: UIView = UIView()
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func showSpinner(activate: Bool, view: UIView) {
        
        if activate {
            opaqueBackgroundView.frame = view.frame
            opaqueBackgroundView.center = view.center
            opaqueBackgroundView.backgroundColor = UIColor.black
            opaqueBackgroundView.alpha = 0.7
            opaqueBackgroundView.clipsToBounds = true
            
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            activityIndicator.center = opaqueBackgroundView.center
            
            opaqueBackgroundView.addSubview(activityIndicator)
            view.addSubview(opaqueBackgroundView)
            activityIndicator.startAnimating()
            
            UIApplication.shared.beginIgnoringInteractionEvents()
        } else {
            UIApplication.shared.endIgnoringInteractionEvents()
            activityIndicator.stopAnimating()
            opaqueBackgroundView.removeFromSuperview()
        }
    }

}
