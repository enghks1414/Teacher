//
//  Tc01TableViewCell.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 6..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit

class Tc01TableViewCell: UITableViewCell {

    @IBOutlet weak var answerCount: UILabel!
    @IBOutlet weak var writeTag: UILabel!
    @IBOutlet weak var writeTime: UILabel!
    @IBOutlet weak var writerName: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var QuestionTextLabel: UILabel!
    
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
