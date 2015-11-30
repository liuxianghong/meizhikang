//
//  MenuTableViewCell.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/11/28.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImage : UIImageView!
    @IBOutlet weak var titleLabel : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor .clearColor()
        let view = UIView(frame: self.bounds)
        view.backgroundColor = UINavigationBar.appearance().barTintColor
        self.selectedBackgroundView = view
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        self.iconImage.highlighted = selected;
        self.titleLabel.textColor = selected ? UIColor.whiteColor() : UIColor.lightGrayColor()
        
    }

}
