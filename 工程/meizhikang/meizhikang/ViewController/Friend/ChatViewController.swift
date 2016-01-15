//
//  ChatViewController.swift
//  meizhikang
//
//  Created by shadowPriest on 15/12/14.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MBProgressHUD
import ISEmojiView
import ObjectiveC
import WYPopoverController

enum JSQMessageSendingStatus: String{
    case Sending
    case Successful
    case Failed
    case None
}

private var jsqSendingStatusKey: UInt8 = 0
extension JSQMessage{
    var sendStauts : JSQMessageSendingStatus {
        get{
            if let retString = objc_getAssociatedObject(self, &jsqSendingStatusKey) as? String,
            let ret = JSQMessageSendingStatus(rawValue: retString){
                return ret
            }else{
                return .Successful
            }
        }
        set(newValue){
            objc_setAssociatedObject(self, &jsqSendingStatusKey, newValue.rawValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}


class ChatViewModel: NSObject,RecordAudioDelegate{
    var messages: [JSQMessage]?
    var avatars: [String: JSQMessagesAvatarImage]?
    var outgoingBubbleImage: JSQMessagesBubbleImage!
    var incomingBubbleImage: JSQMessagesBubbleImage!
    var currentAudioItem: JSQAudioMediaItem?
    var users: [String: String]?
    let recordAudio: RecordAudio
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
        let outImage = UIImage(named: "白对话框.png")?.resizableImageWithCapInsets(UIEdgeInsetsMake(7, 12, 25, 12), resizingMode: .Stretch)
        let inImage = UIImage(named: "蓝对话框.png")?.resizableImageWithCapInsets(UIEdgeInsetsMake(7, 12, 25, 12), resizingMode: .Stretch)
        outgoingBubbleImage = JSQMessagesBubbleImage(messageBubbleImage: outImage, highlightedImage: outImage)
        incomingBubbleImage = JSQMessagesBubbleImage(messageBubbleImage: inImage, highlightedImage: inImage)
        recordAudio = RecordAudio()
        super.init()
        recordAudio.delegate = self
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
    
    func playItemAt(index :Int) -> (String,AnyObject)?{
        let message = self.messages![index];
        if message.isMediaMessage{
            if let media = message.media as? JSQAudioMediaItem{
                self.recordAudio.stopPlay()
                guard media != self.currentAudioItem else{
                    media.endPlaySound()
                    return nil
                }
                self.currentAudioItem = media
                media.startPlaySound()
                var data : NSData?
                if let path = media.fileURL {
                    data = EncodeWAVEToAMR(NSData(contentsOfURL: path), 1, 16)
                }else{
                    data = media.voiceData
                }
                guard let d = data else{
                    return nil
                }
                self.recordAudio.play(d)
            }
            if let media = message.media as? JSQMyPhotoMediaItem{
                return ("ShowImageSegueIdentifier",media.image)
            }
        }
        return nil
    }
    
    //MARK: RecordDelegate
    func RecordStatus(status: Int32) {
        NSLog("status: %d", status)
        if status == 1{
            if let item = self.currentAudioItem {
                item.endPlaySound()
                self.currentAudioItem = nil
            }
        }
    }
}

class ChatViewController: JSQMessagesViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ISEmojiViewDelegate ,WYPopoverControllerDelegate,GroupMoreViewControllerDelegate{

    var currentAvatar: UIImage!
    var receiverId: String!
    var receiverName: String!
    var viewModel: ChatViewModel!
    var group : Group!
    var chat : Chat!
    var sendVoice: UIButton!
    var observer : NSObjectProtocol!
    var voiceTimeInterval : NSTimeInterval = 0
    var emojiView : ISEmojiView!
    var popoverController : WYPopoverController!
    var autoSendImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = UIColor(white: 0.5, alpha: 1.0)

        // Do any additional setup after loading the view.
        viewModel = ChatViewModel(senderId: senderId, senderName: senderDisplayName, displayAvatar: nil, receiverId: receiverId, receiverName: receiverName, receiverAvatar: currentAvatar)
        configInputToolbar()
        
        observer = NSNotificationCenter.defaultCenter().addObserverForName("reciveMessageNotification", object: nil, queue: NSOperationQueue.mainQueue()) { (notification : NSNotification) -> Void in
            let message = notification.object as! Message
            if message.group != nil && message.group == self.group{
                self.group.unReadMessage = 0
                self.addMessage(message)
            }
            else if message.chat != nil && message.chat == self.chat{
                self.chat.unReadMessage = 0
                self.addMessage(message)
            }
        }
        
        if group == nil{
            self.navigationItem.rightBarButtonItem = nil
            if chat != nil{
                chat.unReadMessage = 0
                self.title = chat.member?.nickname
                let messages = Message.MR_findByAttribute("chat", withValue: chat, andOrderBy: "sendtime", ascending: true)
                for message in messages {
                    self.addMessage(message as! Message)
                }
            }
        }
        else{
            group.unReadMessage = 0
            self.title = group.gname
            let messages = Message.MR_findByAttribute("group", withValue: group, andOrderBy: "sendtime", ascending: true)
            for message in messages {
                self.addMessage(message as! Message)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        if !IMRequst.isLogin(){
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    @IBAction func backClick(sneder : AnyObject?){
        self.navigationController?.popViewControllerAnimated(true)
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        sendImage(self.autoSendImage)
        self.autoSendImage = nil
    }
    
    @IBAction func moreClick(sneder : AnyObject?){
        self.performSegueWithIdentifier("groupMoreInderfier", sender: sneder)
    }
    
    func addMessage(message : Message){
        var message2: JSQMessage?
        var sender = receiverId
        var displayName = GroupMember.GroupMemberByUid(message.fromid!)?.nickname
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(message.sendtime!))
        if message.fromid!.isEqualToNumber(UserInfo.CurrentUser()!.uid!){
            sender = self.senderId
            displayName = senderDisplayName
        }
        if message.messageType() == .Text{
            message2 = JSQMessage(senderId: sender, senderDisplayName: displayName, date: date,text: message.text())
        }
        else if message.messageType() == .Image{
            message2 = JSQMessage(senderId: sender, senderDisplayName: displayName, date: date,media: JSQMyPhotoMediaItem(image: message.image()))
        }else if message.messageType() == .Voice{
            let item = JSQAudioMediaItem(data: message.Data()!)
            item.appliesMediaViewMaskAsOutgoing = false
            message2 = JSQMessage(senderId: sender, senderDisplayName: displayName, date: date,media: item)
        }else{
            return
        }
        self.viewModel.messages?.append(message2!)
        self.finishSendingMessageAnimated(true)
    }
    
    func configInputToolbar(){
        if let contentView = self.inputToolbar?.contentView{
            contentView.leftBarButtonItem = nil
            contentView.textView?.returnKeyType = .Send
            contentView.textView?.enablesReturnKeyAutomatically = true
            contentView.rightBarButtonItem = nil
            layoutInputToolbarLeft()
            layoutInputToolbarRight()
            initSendVoiceButton()
            emojiView = ISEmojiView(frame: CGRectMake(0, 0, self.view.frame.size.width, 216))
            emojiView.delegate = self
        }
    }
    
    func initSendVoiceButton(){
        guard let contentView = self.inputToolbar?.contentView else{
            return
        }
        sendVoice = UIButton(type: .Custom)
        sendVoice.setTitle("按住说话", forState: .Normal)
        sendVoice.backgroundColor = UIColor.whiteColor()
        sendVoice.setTitleColor(UIColor.blackColor(), forState: .Normal)
        sendVoice.layer.borderColor = UIColor.blackColor().CGColor
        sendVoice.layer.cornerRadius = 5.0
        sendVoice.layer.borderWidth = 1.0
        sendVoice.addTarget(self, action: "sendVoiceButtonDown:", forControlEvents: .TouchDown)
        sendVoice.addTarget(self, action: "sendVoicButtonUpInside:", forControlEvents: .TouchUpInside)
        sendVoice.addTarget(self, action: "sendVoiceButtonUpOutside:", forControlEvents: .TouchUpOutside)
        contentView.addSubview(sendVoice)
        sendVoice.translatesAutoresizingMaskIntoConstraints = false
        let topConstaint = NSLayoutConstraint(item: sendVoice, attribute: .Top, relatedBy: .Equal, toItem: contentView.textView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let bottomConstaint = NSLayoutConstraint(item: sendVoice, attribute: .Bottom, relatedBy: .Equal, toItem: contentView.textView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let leadingConstaint = NSLayoutConstraint(item: sendVoice, attribute: .Leading, relatedBy: .Equal, toItem: contentView.textView, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let trailingConstaint = NSLayoutConstraint(item: sendVoice, attribute: .Trailing, relatedBy: .Equal, toItem: contentView.textView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        contentView.addConstraint(topConstaint)
        contentView.addConstraint(bottomConstaint)
        contentView.addConstraint(leadingConstaint)
        contentView.addConstraint(trailingConstaint)
        sendVoice.hidden = true
    }
    
    func layoutInputToolbarLeft(){
        guard let contentView = self.inputToolbar?.contentView,
            let containerView = contentView.leftBarButtonContainerView else{
               return
        }
        let btn = buttonWith(UIImage(named: "语音.png"), selector: "mediaClicked:")
        let sticker = buttonWith(UIImage(named: "表情.png"), selector: "stickerClicked:")
        btn.setImage(UIImage(named: "keyboard_btn.png"), forState: .Selected)
        containerView.hidden = false
        containerView.addSubview(sticker)
        containerView.addSubview(btn)
        sticker.translatesAutoresizingMaskIntoConstraints = false
        btn.translatesAutoresizingMaskIntoConstraints = false
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[sticker]-[btn]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["sticker" : sticker,"btn": btn])
        let vconstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[sticker]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["sticker" : sticker])
        containerView.addConstraints(constraints)
        containerView.addConstraints(vconstraints)
        let btnCY = NSLayoutConstraint(item: sticker, attribute: .CenterY, relatedBy: .Equal, toItem: btn, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        containerView.addConstraint(btnCY)
        contentView.leftBarButtonItemWidth = btn.bounds.size.width + sticker.bounds.size.width + 8.0
        contentView.leftContentPadding = 8.0
    }
    
    func layoutInputToolbarRight(){
        let photoButton = buttonWith(UIImage(named: "添加-灰色.png"), selector: "addPhoto:")
        if let containerView = self.inputToolbar?.contentView?.rightBarButtonContainerView{
            containerView.hidden = false
            containerView.addSubview(photoButton)
            photoButton.translatesAutoresizingMaskIntoConstraints = false
            let constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[photoButton]", options: .DirectionLeadingToTrailing, metrics: nil, views: ["photoButton" : photoButton])
            let vconstraint = NSLayoutConstraint(item: photoButton, attribute: .CenterY, relatedBy: .Equal, toItem: containerView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
            self.inputToolbar?.contentView?.rightBarButtonItemWidth = photoButton.bounds.size.width
            containerView.addConstraint(vconstraint)
            containerView.addConstraints(constraints)
            self.inputToolbar?.contentView?.rightContentPadding = 8.0
        }
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
    
    func stickerClicked(sender: UIButton){
        print("showSticker")
        guard let textView = self.inputToolbar?.contentView?.textView else{
            return
        }
        if textView.isFirstResponder(){
            if textView.inputView == emojiView{
                textView.inputView = nil
            }
            else{
                textView.inputView = emojiView
            }
            textView.reloadInputViews()
        }else{
            textView.inputView = emojiView
            textView.becomeFirstResponder()
        }
//        if textView.isFirstResponder(){
////            if let _ = textView.emoticonsKeyboard{
////                textView.switchToDefaultKeyboard()
////            }else{
////                textView.switchToEmoticonsKeyboard(EmotionsKeyboardBuilder.sharedEmoticonsKeyboard())
////            }
//        }else{
//            //textView.switchToEmoticonsKeyboard(EmotionsKeyboardBuilder.sharedEmoticonsKeyboard())
//            //textView.becomeFirstResponder()
//        }
    }
    func mediaClicked(sender: UIButton){
        sender.selected = !sender.selected
        if sender.selected{
            self.inputToolbar?.contentView?.textView?.resignFirstResponder()
            sendVoice.hidden = false
        }else{
            self.inputToolbar?.contentView?.textView?.becomeFirstResponder()
            sendVoice.hidden = true
        }
    }
    func addPhoto(sender: UIButton){
        let actionVC = UIAlertController(title: "", message: "选取图片", preferredStyle: .ActionSheet)
        let actionPhotoLibrary = UIAlertAction(title: "相册", style: .Default, handler: { (ac :UIAlertAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary){
                self.showImagePickVC(.PhotoLibrary)
            }
        })
        let actionCamera = UIAlertAction(title: "拍照", style: .Default, handler: { (UIAlertAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.Camera){
                self.showImagePickVC(.Camera)
            }
        })
        let actionCancel = UIAlertAction(title: "取消", style: .Cancel, handler: { (UIAlertAction) -> Void in
            
        })
        
        actionVC.addAction(actionPhotoLibrary)
        actionVC.addAction(actionCamera)
        actionVC.addAction(actionCancel)
        self.presentViewController(actionVC, animated: true, completion: { () -> Void in
            
        })
    }
    
    func emojiView(emojiView: ISEmojiView!, didSelectEmoji emoji: String!){
        self.inputToolbar?.contentView?.textView?.text = self.inputToolbar?.contentView?.textView?.text.stringByAppendingString(emoji)
    }
    
    func emojiView(emojiView: ISEmojiView!, didPressDeleteButton deletebutton: UIButton!){
        if !(self.inputToolbar?.contentView?.textView?.text)!.isEmpty {
            let endIndex = self.inputToolbar?.contentView?.textView?.text.endIndex.advancedBy(-1)
            self.inputToolbar?.contentView?.textView?.text.removeAtIndex(endIndex!)
        }
    }
    
    func showImagePickVC(sourceType: UIImagePickerControllerSourceType){
        let imagePickerController:UIImagePickerController = UIImagePickerController()
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = false;
        imagePickerController.sourceType = sourceType;
        self.presentViewController(imagePickerController, animated: true) { () -> Void in
            
        }
    }
    
    func sendType() -> IMMsgSendFromType{
        if group != nil{
            return IMMsgSendFromTypeGroup
        }
        else{
            return IMMsgSendFromTypePepole
        }
    }
    
    func sendID() -> NSNumber{
        if group != nil{
            return self.group.gid!
        }
        else{
            return (chat.member?.uid)!
        }
    }
    
    func saveMessage(mesage : Message){
        if group != nil{
            mesage.gid = self.group.gid
            mesage.group = self.group
        }
        else{
            mesage.gid = 0
            mesage.chat = chat
        }
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true) { () -> Void in
            
            if let image : UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.sendImage(image)
            }
        }
    }
    
    func sendVoiceButtonStatus(){
        if sendVoice.selected {
            sendVoice.backgroundColor = UIColor.lightGrayColor()
        }else{
            sendVoice.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func sendVoiceButtonUpOutside(sender: UIButton){
        sender.selected = false
        viewModel.recordAudio.stopRecord()
        sendVoiceButtonStatus()
    }
    
    func sendVoiceButtonDown(sender: UIButton){
        sender.selected = true
        voiceTimeInterval = NSDate().timeIntervalSince1970
        viewModel.recordAudio.stopPlay()
        viewModel.recordAudio.startRecord()
        sendVoiceButtonStatus()
    }
    
    func sendVoicButtonUpInside(sender: UIButton){
        sender.selected = false
        sendVoiceButtonStatus()
        let url = viewModel.recordAudio.stopRecord()
        let endVoiceTimeInterval = NSDate().timeIntervalSince1970
        if endVoiceTimeInterval - voiceTimeInterval < 1{
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.mode = .Text
            hud.detailsLabelText = "录音时间太短"
            hud.hide(true, afterDelay: 0.8)
            return
        }
        else if endVoiceTimeInterval - voiceTimeInterval > 60{
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.mode = .Text
            hud.detailsLabelText = "录音时间过长"
            hud.hide(true, afterDelay: 0.8)
            return
        }
        
        let data = EncodeWAVEToAMR(NSData(contentsOfURL: url), 1, 16)
        IMRequst.UploadFileRequst(data, fileType: IMMsgSendFileTypeVoice, fromType: sendType(), toid: sendID(), completion: { object in
            print(object)
            
            let json = JSON(object)
            let mesage = Message.MR_createEntity()
            mesage.fromid = UserInfo.CurrentUser()?.uid
            mesage.sendtime = json["sendtime"].number
            mesage.content = "[url][/url]"
            mesage.data = data
            self.saveMessage(mesage)
            
            }) { error in
                print(error)
        }
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, media: JSQAudioMediaItem(fileURL: url, isReadyToPlay: true))
        viewModel.messages?.append(message)
        finishSendingMessageAnimated(true)
    }
    
    func sendMessage(text: String, sendId: String, senderDisplayName: String, date: NSDate){
        let jsqmessage = JSQMessage(senderId: sendId, displayName: senderDisplayName, text: text)
        jsqmessage.sendStauts = .Sending
        viewModel.messages?.append(jsqmessage)
        IMRequst.SendMessage(text, fromType: sendType(), toid: sendID(), completion: { (object) -> Void in
            print(object)
            let json = JSON(object)
            let flag = json["flag"].intValue
            if flag == 1{
                print("发送成功")
                jsqmessage.sendStauts = .Successful
                let mesage = Message.MR_createEntity()
                mesage.fromid = UserInfo.CurrentUser()?.uid
                mesage.sendtime = json["sendtime"].number
                mesage.content = "[text]\(text)[/text]"
                self.saveMessage(mesage)
            }
            else
            {
                jsqmessage.sendStauts = .Failed
                print("发送失败")
            }
            }, failure: { (error : NSError!) -> Void in
                jsqmessage.sendStauts = .Failed
        })
        self.finishSendingMessageAnimated(true)
    }
    
    func sendImage(oImage: UIImage?){
        guard let image = oImage else{
            return
        }
        let jsq = JSQMyPhotoMediaItem(image: image)
        let message2 = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, media: jsq)
        message2.sendStauts = .Sending
        self.viewModel.messages?.append(message2!)
        self.finishSendingMessageAnimated(true)
        let data = UIImageJPEGRepresentation(image, 0.1)
        IMRequst.UploadFileRequst(data, fileType: IMMsgSendFileTypeImage, fromType: self.sendType(), toid: self.sendID(), completion: { object in
            print(object)
            message2.sendStauts = .Successful
            let json = JSON(object)
            let mesage = Message.MR_createEntity()
            mesage.fromid = UserInfo.CurrentUser()?.uid
            mesage.sendtime = json["sendtime"].number
            mesage.content = "[image][/image]"
            mesage.saveData(data!)
            mesage.uuid = json["uuid"].number
            self.saveMessage(mesage)
            self.finishSendingMessageAnimated(true)
            }) { error in
            message2.sendStauts = .Failed
                print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
//        let message = JSQMessage(senderId: senderId,
//            displayName: senderDisplayName,
//            text: text)
//        viewModel.messages?.append(message)
//        let message2 = JSQMessage(senderId: receiverId, displayName: receiverName, text: text)
//        viewModel.messages?.append(message2)
//        self.finishSendingMessageAnimated(true)
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
            self.sendMessage(textView.text, sendId: self.senderId, senderDisplayName: self.senderDisplayName, date: NSDate())
            return false
        }
        return true
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
        let mediaMessage = message.isMediaMessage
        if (mediaMessage){
            if let photoItem = message.media as? JSQMyPhotoMediaItem{
                cell?.mediaView = photoItem.mediaView(message.senderId == self.senderId)
                if message.sendStauts == .Successful{
                    MBProgressHUD.hideHUDForView(cell?.mediaView, animated: true)
                }else{
                    let hud = MBProgressHUD.showHUDAddedTo(cell?.mediaView, animated: true)
                    hud.color = UIColor.clearColor()
                    hud.dimBackground = true
                }
            }else if let audioItem = message.media as? JSQAudioMediaItem{
                audioItem.appliesMediaViewMaskAsOutgoing = message.senderId == self.senderId
                cell?.mediaView = audioItem.mediaView()
            }
            
        }
        return cell!
    }
    
    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let superClass = self.superclass else{
            return
        }
        if superClass.instancesRespondToSelector("collectionView:didEndDisplayingCell:forItemAtIndexPath:"){
            super.collectionView(collectionView, didEndDisplayingCell: cell, forItemAtIndexPath: indexPath)
        }
        guard let jsqCell = cell as? JSQMessagesCollectionViewCell else{
            return
        }
        let message = viewModel.messages![indexPath.item]
        let mediaMessage = message.isMediaMessage
        if (mediaMessage){
            MBProgressHUD.hideHUDForView(jsqCell.mediaView, animated: true)
        }
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
    
    // MARK: - JSQMessages Delegate
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        if let (segueIdentifer,image) = self.viewModel.playItemAt(indexPath.row){
            self.performSegueWithIdentifier(segueIdentifer, sender: image)
        }
    }
    
    // MARK: - WY
    
    func popoverControllerDidPresentPopover(popoverController: WYPopoverController!){
        print("popoverControllerDidPresentPopover")
    }
    
    func popoverControllerDidDismissPopover(popoverController: WYPopoverController!){
        print("popoverControllerDidDismissPopover")
    }
    
    // MARK: - GroupMore
    func didClickGroupMoreType(type : GroupMoreType){
        switch type{
        case .GroupMembers:
            self.performSegueWithIdentifier("groupMenbersIndentifier", sender: nil)
        case .GroupMessage:
            self.performSegueWithIdentifier("GroupInformation", sender: nil)
        case .GroupOnShare:
            shareGroup(group)
        case .GroupOffShare:
            shareGroup(nil)
        case .GroupUpdateName:
            groupUpdateName()
        case .GroupDelete:
            deleteGroup()
        case .GroupAddMenber:
            self.performSegueWithIdentifier("addMenberIdentifier", sender: nil)
        case .GroupQuite:
            quiteGroup()
        }
    }
    
    func shareGroup(g : Group?){
        UserInfo.CurrentUser()?.shareGroup = g
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = .Text
        if g == nil{
            hud.detailsLabelText = "取消分享报告成功"
        }
        else{
            hud.detailsLabelText = "启用分享报告成功"
        }
        hud.hide(true, afterDelay: 1)
    }
    
    func quiteGroup(){
        let actionGroup = UIAlertController(title: "", message: "是否要退出组", preferredStyle: .Alert)
        let actionA = UIAlertAction(title: "确定", style: .Default, handler: { (UIAlertAction) -> Void in
            let hud = MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)
            IMRequst.QuitGroupByGid(self.group.gid, completion: { (object) -> Void in
                print(object)
                let joson = JSON(object)
                let flag = joson["flag"].intValue
                if flag == 1{
                    hud.detailsLabelText = "退出组成功";
                    UserInfo.CurrentUser()?.quiteGroup(self.group)
                    self.navigationController?.popViewControllerAnimated(true)
                }
                else if flag == -1{
                    hud.detailsLabelText = "组不存在";
                }
                else{
                    hud.detailsLabelText = "退出组失败";
                }
                hud.mode = .Text
                
                hud.hide(true, afterDelay: 1.5)
                
                }, failure: { (error : NSError!) -> Void in
                    hud.mode = .Text
                    hud.detailsLabelText = error.domain;
                    hud.hide(true, afterDelay: 1.5)
                    print(error)
            })
        })
        
        let actionC = UIAlertAction(title: "取消", style: .Cancel, handler: { (UIAlertAction) -> Void in
            
        })
        actionGroup.addAction(actionA)
        actionGroup.addAction(actionC)
        self.presentViewController(actionGroup, animated: true, completion: { () -> Void in
            
        })
    }
    
    func deleteGroup(){
        
        let actionGroup = UIAlertController(title: "", message: "是否要删除组", preferredStyle: .Alert)
        let actionA = UIAlertAction(title: "确定", style: .Default, handler: { (UIAlertAction) -> Void in
            let hud = MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)
            IMRequst.DeleteGroupByGid(self.group.gid, completion: { (object) -> Void in
                print(object)
                let joson = JSON(object)
                let flag = joson["flag"].intValue
                if flag == 1{
                    hud.detailsLabelText = "删除组成功";
                    UserInfo.CurrentUser()?.quiteGroup(self.group)
                    self.navigationController?.popViewControllerAnimated(true)
                }
                else
                {
                    hud.detailsLabelText = "删除组失败";
                }
                hud.mode = .Text
                
                hud.hide(true, afterDelay: 1.5)
                
                }, failure: { (error : NSError!) -> Void in
                    hud.mode = .Text
                    hud.detailsLabelText = error.domain;
                    hud.hide(true, afterDelay: 1.5)
                    print(error)
            })
        })
        
        let actionC = UIAlertAction(title: "取消", style: .Cancel, handler: { (UIAlertAction) -> Void in
            
        })
        actionGroup.addAction(actionA)
        actionGroup.addAction(actionC)
        self.presentViewController(actionGroup, animated: true, completion: { () -> Void in
            
        })
        
    }
    
    func groupUpdateName(){
        let actionGroup = UIAlertController(title: "", message: "更新组名", preferredStyle: .Alert)
        let actionA = UIAlertAction(title: "确定", style: .Default, handler: { (UIAlertAction) -> Void in
            let tf = actionGroup.textFields![0]
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            IMRequst.UpdateGroupNameByGid(self.group.gid,name:tf.text, completion: { (object) -> Void in
                print(object)
                let joson = JSON(object)
                let flag = joson["flag"].intValue
                if flag == 1{
                    hud.detailsLabelText = "更新组名成功";
                    self.group.gname = joson["gname"].stringValue
                    self.title = self.group.gname
                    NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
                }
                else
                {
                    hud.detailsLabelText = "更新组名失败";
                }
                hud.mode = .Text
                
                hud.hide(true, afterDelay: 1.5)
                
                }, failure: { (error : NSError!) -> Void in
                    hud.mode = .Text
                    hud.detailsLabelText = error.domain;
                    hud.hide(true, afterDelay: 1.5)
                    print(error)
            })
        })
        
        let actionC = UIAlertAction(title: "取消", style: .Cancel, handler: { (UIAlertAction) -> Void in
            
        })
        actionGroup.addTextFieldWithConfigurationHandler({ (textField : UITextField) -> Void in
            textField.placeholder = "请输入新组名"
        })
        actionGroup.addAction(actionA)
        actionGroup.addAction(actionC)
        self.presentViewController(actionGroup, animated: true, completion: { () -> Void in
            
        })
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "groupMoreInderfier"{
            let vc = segue.destinationViewController as! GroupMoreTableViewController
            vc.tableViewArray.append(.GroupMembers)
            vc.tableViewArray.append(.GroupMessage)
            if UserInfo.CurrentUser()?.shareGroup == nil{
                vc.tableViewArray.append(.GroupOnShare)
            }
            else if group == UserInfo.CurrentUser()?.shareGroup{
                vc.tableViewArray.append(.GroupOffShare)
            }
            if group.owner == UserInfo.CurrentUser()?.uid{
                vc.tableViewArray.append(.GroupUpdateName)
                vc.tableViewArray.append(.GroupDelete)
                vc.tableViewArray.append(.GroupAddMenber)
            }
            else{
                vc.tableViewArray.append(.GroupQuite)
            }
            vc.preferredContentSize = CGSizeMake(120.0, CGFloat(vc.tableViewArray.count * 46))
            vc.delegate = self
            let popoverSegue = segue as! WYStoryboardPopoverSegue;
            popoverController = popoverSegue.popoverControllerWithSender(sender, permittedArrowDirections: .Any, animated: true)
            popoverController.delegate = self
            popoverController.dismissOnTap = true
            popoverController.theme.outerCornerRadius = 0
            popoverController.theme.innerCornerRadius = 0
            popoverController.theme.glossShadowColor = UIColor.clearColor()
            popoverController.theme.fillTopColor = UIColor.clearColor()
            popoverController.theme.fillBottomColor = UIColor.clearColor()
            popoverController.theme.arrowHeight = 10
            popoverController.popoverLayoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        }
        else if segue.identifier == "GroupInformation"{
            let vc = segue.destinationViewController as! GroupInformationTableViewController
            vc.group = group
        }
        else if segue.identifier == "groupMenbersIndentifier"{
            let vc = segue.destinationViewController as! GroupMenbersTableViewController
            vc.group = group
        }
        else if segue.identifier == "addMenberIdentifier"{
            let vc = segue.destinationViewController as! GroupAddMenbersViewController
            vc.group = group
        }else if segue.identifier == "ShowImageSegueIdentifier" {
            let vc = segue.destinationViewController as! ChatImageViewController
            vc.image = sender as? UIImage
        }
        
    }


}
