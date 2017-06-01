//
//  MatchUserViewController.swift
//  TinderClone
//
//  Created by Marcelo Mogrovejo on 7/5/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import UIKit
import Parse

class MatchUserViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var optionsLabel: UILabel!
    
    var displayedUserId: String = ""
    
    let util: Util = Util()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.wasDragged(gestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(gesture)
        
        PFGeoPoint.geoPointForCurrentLocation { (geopoint, error) in
            
            if let geopoint = geopoint {
                
                PFUser.current()?["location"] = geopoint
                
                PFUser.current()?.saveInBackground()
            }
        }
        
        updateImage()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logOutSegue" {
            PFUser.logOut()
        }
    }
    
    // MARK: - Private methods
    
    func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        
        let translation = gestureRecognizer.translation(in: view)
        let label = gestureRecognizer.view!
        label.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        let xFromCenter = label.center.x - self.view.bounds.width / 2
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 200)
        let scale = min(abs(100 / xFromCenter), 1)
        var stretchAndRotation = rotation.scaledBy(x: scale, y: scale)
        label.transform = stretchAndRotation
        
        if gestureRecognizer.state == UIGestureRecognizerState.ended {
            
            var acceptedOrRejected: String
            
            if label.center.x < 100 {
                acceptedOrRejected = "rejected"
            } else {
                acceptedOrRejected = "accepted"
            }
            
            if acceptedOrRejected != "" && displayedUserId != "" {
                
                PFUser.current()?.addUniqueObjects(from: [displayedUserId], forKey: acceptedOrRejected)
                
                PFUser.current()?.saveInBackground(block: { (success, error) in
                    self.updateImage()
                })
                
            }
            rotation = CGAffineTransform(rotationAngle: 0)
            stretchAndRotation = rotation.scaledBy(x: 1, y: 1)
            label.transform = stretchAndRotation
            label.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
        }
        
    }
    
    func updateImage() {
        
        util.showSpinner(activate: true, view: view)
        
        let query = PFUser.query()
        query?.whereKey("isFemale", equalTo: (PFUser.current()?["isInterestedInWomen"])!)
        query?.whereKey("isInterestedInWomen", equalTo: (PFUser.current()?["isFemale"])!)
        
        var ignoredUsers = [""]
        
        if let acceptedUsers = PFUser.current()?["accepted"] {
            ignoredUsers += acceptedUsers as! Array
        }
        
        if let rejectedUsers = PFUser.current()?["rejected"] {
            ignoredUsers += rejectedUsers as! Array
        }
        query?.whereKey("objectId", notContainedIn: ignoredUsers)
        
        // WARNING: commented just for testing purposes
        
//        if let latitude = (PFUser.current()?["location"] as AnyObject).latitude {
//            if let longitude = (PFUser.current()?["location"] as AnyObject).longitude {
//                
//                query?.whereKey("location", withinGeoBoxFromSouthwest: PFGeoPoint(latitude: latitude - 1, longitude: longitude - 1), toNortheast: PFGeoPoint(latitude: latitude + 1, longitude: longitude + 1))
//                
//            }
//        }
        
        query?.limit = 1
        query?.findObjectsInBackground(block: { (objects, error) in
            
            if let users = objects {

                if users.count > 0 {
                    
                    for object in users {
                        
                        if let user = object as? PFUser {
                            
                            self.displayedUserId = user.objectId!
                            
                            let imageFile = user["photo"] as! PFFile
                            imageFile.getDataInBackground(block: { (data, error) in
                                
                                if let imageData = data {
                                    self.imageView.image = UIImage(data: imageData)
                                }
                                
                            })
                        }
                    }
                } else {

                    // TODO: it became anoying, create a label
                    
//                    let alertController = UIAlertController(title: NSLocalizedString("No more users", comment: "No more users alert title"), message: NSLocalizedString("Try later to get more users around.", comment: "No more users alert message"), preferredStyle: .alert)
//                    
//                    let acceptAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Accept action button label"), style: .default, handler: { (UIAlertAction) in
//                        alertController.dismiss(animated: true, completion: nil)
//                        self.imageView.image = UIImage(named: "defaultImage")
//                    })
//                    
//                    alertController.addAction(acceptAction)
//                    
//                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
            self.util.showSpinner(activate: false, view: self.view)
        })
        
    }
    
}
