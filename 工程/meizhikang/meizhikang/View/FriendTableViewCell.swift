//
//  FriendTableViewCell.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/12/2.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var typeImageView : UIImageView!
    @IBOutlet weak var numberLabel : UILabel!
    @IBOutlet weak var uiReadView : UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        uiReadView.layer.cornerRadius = 4
        uiReadView.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
