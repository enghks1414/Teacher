//
//  Tc03ChatTableViewCell.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 9..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit

class Tc03ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var chatTime: UILabel!
    @IBOutlet weak var chatText: UILabel!
    @IBOutlet weak var chatName: UILabel!
    @IBOutlet weak var pofileImg: RoundedImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
