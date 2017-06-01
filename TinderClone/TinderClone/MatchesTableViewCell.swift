//
//  MatchesTableViewCell.swift
//  TinderClone
//
//  Created by Marcelo Mogrovejo on 15/5/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import UIKit
import Parse

class MatchesTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var messagesLabel: UILabel!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var userIdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Action methods
    
    @IBAction func send(_ sender: Any) {
        
        print(userIdLabel.text!)
        print(messageTextField.text!)
        
        let message = PFObject(className: "Message")
        message["sender"] = PFUser.current()?.objectId!
        message["recipient"] = userIdLabel.text
        message["content"] = messageTextField.text
        
        message.saveInBackground()
        
    }

}
