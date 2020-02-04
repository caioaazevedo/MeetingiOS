//
//  ContinueOnboardingTableViewCell.swift
//  MeetingiOS
//
//  Created by Lucas Costa  on 30/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import UIKit

class ContinueOnboardingTableViewCell: UITableViewCell {

    @IBOutlet weak var continueButton : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.continueButton.clipsToBounds = true
        self.continueButton.layer.cornerRadius = 5  
        self.continueButton.setTitle(NSLocalizedString("Continue", comment: ""), for: .normal)
    }

}