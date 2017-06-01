//
//  MatchesViewController.swift
//  TinderClone
//
//  Created by Marcelo Mogrovejo on 15/5/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import UIKit
import Parse

class MatchesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var images = [UIImage]()
    var userIds = [String]()
    var messages = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query = PFUser.query()
        query?.whereKey("accepted", contains: PFUser.current()?.objectId)
        query?.whereKey("objectId", containedIn: PFUser.current()?["accepted"] as! [String])
        query?.findObjectsInBackground(block: { (objects, error) in
            
            if let users = objects {
                for object in users {
                    if let user = object as? PFUser {
                        let imageFile = user["photo"] as! PFFile
                        imageFile.getDataInBackground(block: { (data, error) in
                            
                            if let imageData = data {
                                
                                let messageQuery = PFQuery(className: "Message")
                                messageQuery.whereKey("recipient", equalTo: (PFUser.current()?.objectId!)!)
                                messageQuery.whereKey("sender", equalTo: user.objectId!)
                                messageQuery.findObjectsInBackground(block: { (objects, error) in
                                    
                                    var messageText = "No message from this user."
                                    
                                    if let messages = objects {
                                        
                                        for message in messages {
                                            
                                            if let messageContent = message["content"] as? String {
                                                
                                                messageText = messageContent
                                                
                                            }
                                        }
                                    }
                                    
                                    self.messages.append(messageText)
                                    self.images.append(UIImage(data: imageData)!)
                                    self.userIds.append(user.objectId!)
                                    
                                    self.tableView.reloadData()

                                })
                            }
                        })
                    }
                }
            }
        })
        
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITableViewDataSource
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! MatchesTableViewCell
        
        cell.messageTextField.delegate = self
        
        cell.userIdLabel.text = userIds[indexPath.row]
        cell.userImageView.image = images[indexPath.row]
        cell.messagesLabel.text = messages[indexPath.row]
        
        return cell
    }
    
    // MARK: - UITextFieldDelegate
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
