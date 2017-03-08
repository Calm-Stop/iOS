//
//  HistoryTableViewCell.swift
//  CalmStopOfficer
//
//  Created by Douglas MacbookPro on 2/27/17.
//  Copyright © 2017 Douglas MacbookPro. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var driversNameLabel: UILabel!
    @IBOutlet weak var separatorImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
