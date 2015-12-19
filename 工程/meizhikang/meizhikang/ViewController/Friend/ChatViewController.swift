//
//  ChatViewController.swift
//  meizhikang
//
//  Created by shadowPriest on 15/12/14.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatViewModel: NSObject{
    var messages: [JSQMessage]?
    var avatars: [String: JSQMessagesAvatarImage]?
    var outgoingBubbleImage: JSQMessagesBubbleImage!
    var incomingBubbleImage: JSQMessagesBubbleImage!
    var users: [String: String]?
    init(senderId: String!,senderName: String!,displayAvatar : UIImage?,receiverId: String!,receiverName: String!,receiverAvatar: UIImage!){
        messages = []
        var avatarImage: JSQMessagesAvatarImage!
        if let image = displayAvatar{
            avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: 30)
        }else{
            avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named:"联系人-蓝.png"), diameter: 30)
        }
        avatars = [senderId : avatarImage,
            receiverId: JSQMessagesAvatarImageFactory.avatarImageWithImage(receiverAvatar, diameter: 30)]
        users = [senderId : senderName,
            receiverId: receiverName]
        let factory = JSQMessagesBubbleImageFactory(bubbleImage: UIImage(named: "白对话框.png"), capInsets: UIEdgeInsetsMake(12, 16, 12, 16))
        outgoingBubbleImage = factory.outgoingMessagesBubbleImageWithColor(UIColor.whiteColor())
        incomingBubbleImage = factory.incomingMessagesBubbleImageWithColor(UIColor(red: 35.0/255.0, green: 222.0/255.0, blue: 191.0/255.0, alpha: 1.0))
    }
    
    func bubbleImage(senderId :String,index :Int)->JSQMessageBubbleImageDataSource!{
        let message = self.messages![index]
        if message.senderId == senderId{
            return incomingBubbleImage
        }
        return outgoingBubbleImage
    }
    
    func avatarImage(senderId :String)->JSQMessageAvatarImageDataSource!{
        return avatars![senderId]
    }
    
    func attributeTextForCellTopLabel(index :Int)->NSAttributedString?{
        if index % 3 == 0{
            let message = messages![index]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        return nil
    }
    
    func attributeTextForBubbleTopLabel(senderId:String,index: Int)->NSAttributedString?{
        let message = messages![index]
        if message.senderId == senderId{
            return nil
        }
        return NSAttributedString(string: message.senderDisplayName)
    }
    
}

class ChatViewController: JSQMessagesViewController {

    var currentAvatar: UIImage!
    var receiverId: String!
    var receiverName: String!
    var viewModel: ChatViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = UIColor(white: 0.5, alpha: 1.0)

        // Do any additional setup after loading the view.
        viewModel = ChatViewModel(senderId: senderId, senderName: senderDisplayName, displayAvatar: nil, receiverId: receiverId, receiverName: receiverName, receiverAvatar: currentAvatar)
        configInputToolbar()
    }
    
    func configInputToolbar(){
        let sticker = buttonWith(UIImage(named: "表情.png"), selector: nil)
        self.inputToolbar?.contentView?.leftBarButtonItem = sticker
        self.inputToolbar?.contentView?.textView?.returnKeyType = .Send
        self.inputToolbar?.contentView?.textView?.enablesReturnKeyAutomatically = true
        self.inputToolbar?.contentView?.rightBarButtonItem = buttonWith(UIImage(named: "添加-灰色.png"), selector: nil)
        self.inputToolbar?.contentView?.rightBarButtonItem?.enabled = true
        let btn = buttonWith(UIImage(named: "语音.png"), selector: nil)
        sticker.removeFromSuperview()
        self.inputToolbar?.contentView?.leftBarButtonContainerView?.addSubview(sticker)
        self.inputToolbar?.contentView?.leftBarButtonContainerView?.addSubview(btn)
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[sticker][btn]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["sticker" : sticker,"btn": btn])
        let vconstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[sticker]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["sticker" : sticker])
        self.inputToolbar?.contentView?.leftBarButtonContainerView?.addConstraints(constraints)
        self.inputToolbar?.contentView?.leftBarButtonContainerView?.addConstraints(vconstraints)
        let btnCY = NSLayoutConstraint(item: sticker, attribute: .CenterY, relatedBy: .Equal, toItem: btn, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        self.inputToolbar?.contentView?.leftBarButtonContainerView?.addConstraint(btnCY)
        self.inputToolbar?.contentView?.leftBarButtonContainerView
//        self.inputToolbar?.contentView?.leftBarButtonContainerView?.removeConstraint(self.inputToolbar?.contentView?.leftBarButtonItemWidth)
//        self.inputToolbar?.contentView?.leftBarButtonItemWidth = btn.bounds.size.width + sticker.bounds.size.width
    }
    
    func buttonWith(image: UIImage?,selector:Selector?) -> UIButton{
        let button = UIButton(type: .Custom)
        button.setImage(image, forState: .Normal)
        if let sel = selector{
            button.addTarget(self, action: sel, forControlEvents: .TouchUpInside)
        }
        button.sizeToFit()
        return button
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = JSQMessage(senderId: senderId,
            displayName: senderDisplayName,
            text: text)
        viewModel.messages?.append(message)
        let message2 = JSQMessage(senderId: receiverId, displayName: receiverName, text: text)
        viewModel.messages?.append(message2)
        self.finishSendingMessageAnimated(true)
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        print(sender)
    }
    
    
    // MARK: - Text Delegate
    override func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if textView != self.inputToolbar?.contentView?.textView{
            return true
        }
        if text == "\n"{
            return false
        }
        return true
    }
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        if textView != self.inputToolbar?.contentView?.textView{
            return
        }
        self.inputToolbar?.contentView?.rightBarButtonItem?.enabled = true
    }

    // MARK: - JSQMessage Collection DataSource
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return viewModel.messages![indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        viewModel.messages?.removeAtIndex(indexPath.item)
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        return viewModel.bubbleImage(senderId, index: indexPath.item)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return viewModel.avatarImage(senderId)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return viewModel.attributeTextForCellTopLabel(indexPath.item)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return viewModel.attributeTextForBubbleTopLabel(self.senderId, index: indexPath.item)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return nil
    }
    
    // MARK: - UICollectionView DataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (viewModel.messages?.count)!
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as? JSQMessagesCollectionViewCell
        let message = viewModel.messages![indexPath.item]
        if message.senderId == self.senderId{
            cell?.textView?.textColor = UIColor.whiteColor()
        }else{
            cell?.textView?.textColor = UIColor.blackColor()
        }
        return cell!
    }
    
    // MARK: - JSQMessages collection view flow layout delegate
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0{
            return 20.0
        }
        return 0.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if let _ = viewModel.attributeTextForBubbleTopLabel(senderId, index: indexPath.item){
            return 20.0
        }
        return 0.0
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
