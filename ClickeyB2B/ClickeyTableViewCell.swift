//
//  ClickeTableViewCell.swift
//  ClickeyB2B
//
//  Created by Ben Smith on 05/10/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import UIKit

class ClickeyTableViewCell: UITableViewCell {

    @IBOutlet var descriptionClickey: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
