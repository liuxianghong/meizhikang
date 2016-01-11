//
//  UIImage+DrawView.swift
//  meizhikang
//
//  Created by shadowPriest on 16/1/11.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

import Foundation
import QuartzCore
extension UIImage{
    static func imageWith(view: UIView) -> UIImage?{
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0)
        defer{
            UIGraphicsEndImageContext()
        }
        guard let ctx = UIGraphicsGetCurrentContext() else{
            return nil
        }
        view.layer.renderInContext(ctx)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}