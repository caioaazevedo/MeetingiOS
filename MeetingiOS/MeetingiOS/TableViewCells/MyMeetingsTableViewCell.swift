//
//  MyMeetingsTableViewCell.swift
//  MeetingiOS
//
//  Created by Bernardo Nunes on 10/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit

class MyMeetingsTableViewCell: UITableViewCell {

    @IBOutlet weak var meetingName: UILabel!
    @IBOutlet weak var meetingDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    @IBAction func didPressInfo(_ sender: Any) {
        
    }
}
