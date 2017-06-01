//
//  LogInViewController.swift
//  TinderClone
//
//  Created by Marcelo Mogrovejo on 4/5/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import UIKit
import Parse
import FBSDKLoginKit
import SwiftyJSON

class LogInViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var secondaryButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: - Properties
    
    var isLogIn = true
    let util: Util = Util()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        /*******
         * Descomment those lines to populate the database in the first startup
         *******/
//        let populateUsers = PopulateUsers()
//        populateUsers.createUsers()
        

        
        let push = PFPush()
        push.setMessage("This is a test message sent through the application")
        push.sendInBackground { (success: Bool, error: Error?) in
            print(success)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        redirectUser()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Action methods
    
    @IBAction func logInOrSignUp(_ sender: Any) {
        
        self.errorLabel.text = ""
        
        if let usernameText = usernameTextField.text {

            if let passwordText = passwordTextField.text {
                
                if usernameText != "" && passwordText != "" {
                    
                    if isLogIn {
                        
                        print("Logging in...")

                        PFUser.logInWithUsername(inBackground: usernameText, password: passwordText, block: { (user, error) in
                            
                            if error != nil {
                                //TODO: error handler
                                let err = error! as NSError
                                print(err.userInfo["error"]!)
                                
                                self.errorLabel.text = err.userInfo["error"]! as? String
                            } else {
                                
                                // User logged in
                                print("User logged in successfully")
                                
                                //self.performSegue(withIdentifier: "showProfileSegue", sender: self)
                                self.redirectUser()
                                
                            }
                            
                        })
                        
                    } else {
                        
                        print("Signing up...")
                        
                        let user = PFUser()
                        user["username"] = usernameText
                        user["password"] = passwordText
                        
                        // Create an ACL to let the current user save data
                        // In my case the user could write on the server with Public Read ACP only, why??
//                        let acl = PFACL()
//                        acl.getPublicReadAccess = true
//                        user.acl = acl
                        
                        user.signUpInBackground(block: { (success, error) in
                            
                            if error != nil {
                                //TODO: error handler
                                let err = error! as NSError
                                print(err.userInfo["error"]!)
                                
                                self.errorLabel.text = err.userInfo["error"]! as? String
                            } else {
                                
                                // User added
                                print("User added successfully")

                                self.performSegue(withIdentifier: "showProfileSegue", sender: self)
                            }
                            
                        })

                    }

                } else {
                    //TODO: create alert or red message
                }

            }
            
        }
        
    }

    @IBAction func changeMainButtonAction(_ sender: Any) {
    
        if isLogIn {

            // Change to SignUp
            mainButton.setTitle(NSLocalizedString("Sign Up", comment: "Main button title for sign up action"), for: [])
            secondaryButton.setTitle(NSLocalizedString("Log In", comment: "Secondary button log in title"), for: [])
            questionLabel.text = NSLocalizedString("Already have an account?", comment: "To log in question")
            
            isLogIn = false
            
        } else {

            // Change to LogIn
            mainButton.setTitle(NSLocalizedString("Log In", comment: "Main button title for log in action"), for: [])
            secondaryButton.setTitle(NSLocalizedString("Sign Up", comment: "Secondary button sign up title"), for: [])
            questionLabel.text = NSLocalizedString("Do not have an account yet?", comment: "To sign up question")
            
            isLogIn = true
            
        }
        
    }
    
    @IBAction func facebookLogIn(_ sender: Any) {
        
        util.showSpinner(activate: true, view: view)
        
        let facebookLoginManager: FBSDKLoginManager = FBSDKLoginManager()
        facebookLoginManager.logOut()
        facebookLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result: FBSDKLoginManagerLoginResult?, error: Error?) in
            
            if error != nil {
                fatalError("Error logging in on Facebook")
                self.util.showSpinner(activate: false, view: self.view)
            } else if (result?.isCancelled)! {
                print("User cancelled log in on Facebook")
                self.util.showSpinner(activate: false, view: self.view)
            } else {
            
                let facebookLoginResult: FBSDKLoginManagerLoginResult = result!
                if facebookLoginResult.grantedPermissions != nil {
                    if facebookLoginResult.grantedPermissions.contains("email") {
                        self.getFacebookUserData()
                        self.util.showSpinner(activate: false, view: self.view)
                    }
                }
            }
            
        }
        
    }
    
    // MARK: - Private methods
    
    func getFacebookUserData() {
        
        if FBSDKAccessToken.current() != nil {
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection: FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
                
                if error == nil {

                    let jsonData = JSON(result!)
                    print(jsonData)
                    
                    let query = PFUser.query()
                    query?.whereKey("facebookUserId", equalTo: jsonData["id"].rawValue)
                    query?.limit = 1
                    query?.findObjectsInBackground(block: { (objects, error) in
                        
                        if let users = objects {
                            
                            if users.count > 0 {
                                
                                // Log in
                                
                                print("Logging in with existing facebook account...")
                                
                                // TODO: figure out a way to avoid the password or a way to pass the correct password
                                PFUser.logInWithUsername(inBackground: users[0]["username"] as! String, password: "1234567890", block: { (user, error) in
                                    
                                    if error != nil {
                                        //TODO: error handler
                                        let err = error! as NSError
                                        print(err.userInfo["error"]!)
                                        
                                        self.errorLabel.text = err.userInfo["error"]! as? String
                                    } else {
                                        
                                        // User logged in
                                        print("User logged in successfully")
                                        
                                        //self.performSegue(withIdentifier: "showProfileSegue", sender: self)
                                        self.redirectUser()
                                        
                                    }
                                    
                                })
                                
                            } else {
                         
                                // Sign up
                                
                                print("Signing up with a facebook account...")
                                
                                self.getImageDataFomUrl(sourceUrl: jsonData["picture"]["data"]["url"].rawString()!) { (data, response, error) in
                                    
                                    guard let imageData = data, error == nil else { return }
                                    
                                    // TODO: figure out a way to set an encrypted password or a way to not use a password for facebook users.
                                    let user = PFUser()
                                    user["username"] = jsonData["email"].rawValue
                                    user["password"] = "1234567890"
                                    user["photo"] = PFFile(name: "profile.png", data: imageData)
                                    user["facebookUserId"] = jsonData["id"].rawValue
                                    
                                    // Create an ACL to let the current user save data
                                    // In my case the user could write on the server with Public Read ACP only, why??
                                    //                        let acl = PFACL()
                                    //                        acl.getPublicReadAccess = true
                                    //                        user.acl = acl
                                    
                                    user.signUpInBackground(block: { (success, error) in
                                        
                                        if error != nil {
                                            //TODO: error handler
                                            let err = error! as NSError
                                            print(err.userInfo["error"]!)
                                            
                                            self.errorLabel.text = err.userInfo["error"]! as? String
                                        } else {
                                            
                                            // User added
                                            print("User added successfully")
                                            
                                            self.performSegue(withIdentifier: "showProfileSegue", sender: self)
                                        }
                                        
                                    })
                                    
                                }

                            }
                        }
                        
                    })
                }
                
//                self.util.showSpinner(activate: false, view: self.view)
            })
            
        }
    }
    
    func redirectUser() {
        
        if PFUser.current() != nil {
            if PFUser.current()?["isFemale"] != nil && PFUser.current()?["isInterestedInWomen"] != nil && PFUser.current()?["photo"] != nil {
                performSegue(withIdentifier: "showMatchSegue", sender: self)
            } else {
                performSegue(withIdentifier: "showProfileSegue", sender: self)
            }
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

