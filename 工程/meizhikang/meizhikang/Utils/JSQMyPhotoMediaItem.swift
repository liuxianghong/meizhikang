//
//  JSQMyPhotoMediaItem.swift
//  meizhikang
//
//  Created by shadowPriest on 16/1/8.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class JSQMyPhotoMediaItem: JSQPhotoMediaItem {
    var cachedView: UIView?

    func mediaView(outgoing: Bool) -> UIView! {
        if let retView = cachedView{
            return retView
        }
        let size = CGSizeMake(210, 150)
        let imageView = UIImageView(image: self.image)
        imageView.frame = CGRectMake(0.0, 0.0, size.width, size.height)
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        var image : UIImage?
        if outgoing{
            image = UIImage(named: "蓝对话框.png")
        }else{
            image = UIImage(named: "白对话框.png")
        }
        let factory = JSQMessagesBubbleImageFactory(bubbleImage: image, capInsets: UIEdgeInsetsMake(7, 12, 25, 12))
        let mask = JSQMessagesMediaViewBubbleImageMasker(bubbleImageFactory: factory)
        mask.applyOutgoingBubbleImageMaskToMediaView(imageView)
        cachedView = imageView
        return cachedView
    }
}
