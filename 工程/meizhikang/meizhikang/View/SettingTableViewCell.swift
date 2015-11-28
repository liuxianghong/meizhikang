//
//  SettingTableViewCell.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/11/29.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

class SettingTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var backImageView : UIImageView!
    @IBOutlet weak var stateImageView : UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let view = UIView(frame: self.bounds);
        view.backgroundColor = UIColor.clearColor();
        self.selectedBackgroundView = view;
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        backImageView.highlighted = selected;
    }

}
