//
//  ProfileViewController.swift
//  TinderClone
//
//  Created by Marcelo Mogrovejo on 4/5/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var genderSwitch: UISwitch!
    @IBOutlet weak var interestedInSwitch: UISwitch!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    var imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // image picker init
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        
        // Update the form values for current user
        if let isFemale = PFUser.current()?["isFemale"] as? Bool {
            genderSwitch.setOn(isFemale, animated: false)
        }
        
        if let isInterestedInWomen = PFUser.current()?["isInterestedInWomen"] as? Bool {
            interestedInSwitch.setOn(isInterestedInWomen, animated: false)
        }
        
        if let photoFile = PFUser.current()?["photo"] as? PFFile {
            
            photoFile.getDataInBackground(block: { (data, error) in
            
                if error != nil {
                    let parseError = error! as NSError
                    print(parseError.userInfo["error"]!)
                } else {
                    if let imageData = data {
                        
                        if let downloadedImage = UIImage(data: imageData) {
                            
                            self.profileImageView.image = downloadedImage
                            
                        }
                    }
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Action methods
    
    @IBAction func pickImage(_ sender: Any) {
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func takePhoto(_ sender: Any) {
        imagePickerController.sourceType = UIImagePickerControllerSourceType.camera
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func update(_ sender: Any) {
        
        PFUser.current()?["isFemale"] = genderSwitch.isOn
        PFUser.current()?["isInterestedInWomen"] = interestedInSwitch.isOn
        
        let imageData = profileImageView.image!.jpeg(.low)
        PFUser.current()?["photo"] = PFFile(name: "profile.jpg", data: imageData!)
        
        PFUser.current()?.saveInBackground(block: { (success, error) in
            
            if error != nil {
                var errorText = "Update failed - please try again"
                
                let parseError = error! as NSError
                if let errorMessage = parseError.userInfo["error"] as? String {
                    errorText = errorMessage
                }
                self.errorMessageLabel.text = errorText
                
            } else {
                print("Updated")
                
                self.performSegue(withIdentifier: "showMatchUserSegue", sender: self)
                
                
            }
        })
        
    }
    
//    @IBAction func logOut(_ sender: Any) {
//        
//        PFUser.logOut()
//        
//        performSegue(withIdentifier: "logOutSegue", sender: self)
//
//    }
    
    // MARK: - UIImagePickerControllerDelegate methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImageView.image = image
        } else {
            print("There was a problem getting the image")
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
