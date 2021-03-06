//
//  MessagesTableViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 06.10.15.
//  Copyright © 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

class MessagesTableViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let picker = UIImagePickerController()
    
    var event: Event?
    var group: Category?
    var messages:[JSQMessage] = []
    
    var avatars:[String:JSQMessagesAvatarImage] = [:]
    let dateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        
        self.edgesForExtendedLayout = UIRectEdge.None
        inputToolbar?.contentView?.leftBarButtonItem?.setImage(UIImage(named: "add-photo-vid"), forState: .Normal)
        inputToolbar?.contentView?.leftBarButtonItem?.setImage(UIImage(named: "add-photo-vid"), forState: .Highlighted)
        
        inputToolbar?.contentView?.layer.borderWidth = 1
        inputToolbar?.contentView?.layer.borderColor = Color.DefaultBorderColor.CGColor
        inputToolbar!.contentView!.textView!.placeHolder = "Message..."
        inputToolbar!.contentView!.textView!.layer.borderWidth = 1
        inputToolbar?.contentView?.textView!.layer.borderColor = Color.DefaultBorderColor.CGColor
        inputToolbar!.contentView!.textView!.layer.cornerRadius = 0
        inputToolbar?.contentView?.backgroundColor = Color.PrimaryBackgroundColor
        inputToolbar?.contentView?.textView?.frame.size = CGSize(width: (inputToolbar?.contentView?.textView?.frame.width)!,height: (inputToolbar?.contentView?.frame.height)!)
        
        if event != nil {
            UIApplication.sharedApplication().applicationIconBadgeNumber -= Prefs.removeMessage(event!.objectId!)
            //        self.appDelegate.leftViewController.messagesCountLabel.text = "\(Prefs.getMessagesCount())"
            
            title = event!.name
        } else {
            UIApplication.sharedApplication().applicationIconBadgeNumber -= Prefs.removeMessage(group!.objectId!)
            //        self.appDelegate.leftViewController.messagesCountLabel.text = "\(Prefs.getMessagesCount())"
            
            title = group!.name
        }
        
        dateFormatter.dateFormat = "MM/dd/yy h:mm a"
        
        
        if event != nil {
        event!.fetchInBackgroundWithBlock({
            result, error in
            
            self.processAttendees(self.event!.attendees)
            
            ParseHelper.getMessages(self.event!, block: {
                result, error in
                if error == nil {
                    self.processMessages(result!)
                    self.finishReceivingMessage()
                } else {
                    MessageToUser.showDefaultErrorMessage("Something went wrong.")
                }
            })
        })
        } else {
            group!.fetchInBackgroundWithBlock({
                result, error in
                
                self.processAttendees(self.group!.attendees)
                
                ParseHelper.getMessages(self.group!, block: {
                    result, error in
                    if error == nil {
                        self.processMessages(result!)
                        self.finishReceivingMessage()
                    } else {
                        MessageToUser.showDefaultErrorMessage("Something went wrong.")
                    }
                })
            })
        }
        
        self.senderId = PFUser.currentUser()!.objectId;
        self.senderDisplayName = PFUser.currentUser()!.name
        
        self.collectionView!.collectionViewLayout.springinessEnabled = false
        
    }
    
    func processAttendees(result:[PFUser]){
        for attendee in result {
            attendee.fetchInBackgroundWithBlock({
                result, error in
                if error == nil {
                    attendee.getImage({
                        result in
                        self.avatars[attendee.objectId!] = JSQMessagesAvatarImageFactory.avatarImageWithImage(result, diameter: 45)
                    })
                } else {
                    self.avatars[attendee.objectId!] = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "upload_pic"), diameter: 45)
                }
            })
        }
    }
    
    func processMessages(result:[Message]){
        for (index,message) in result.enumerate() {
            
            if message.photo == nil {
                self.messages.append(JSQMessage(senderId: message.user.objectId, senderDisplayName: message.user.name, date: message.createdAt, text: message.text))
            } else {
                let media = JSQPhotoMediaItem()
                message.photo!.getDataInBackgroundWithBlock({
                    result, error in
                    if error == nil {
                        media.image = UIImage(data: result! )
                        self.collectionView!.reloadItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
                    }
                })
                
                self.messages.append(JSQMessage(senderId: message.user.objectId, senderDisplayName: message.user.name, date: message.createdAt, media: media))
                
            }
            
        }
    }
    
    
    override func didPressAccessoryButton(sender: UIButton!) {
        let alert = UIAlertController(title: "Choose Option", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction) in
            self.picker.allowsEditing = true
            self.picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.picker.cameraCaptureMode = .Photo
            self.picker.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
            self.picker.showsCameraControls = true;
            self.presentViewController(self.picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "From Library", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction) in
            self.picker.allowsEditing = true //2
            self.picker.sourceType = .PhotoLibrary //3
            self.picker.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
            self.presentViewController(self.picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func loadMessage(id:String) {
        let message = Message()
        message.objectId = id
        message.fetchInBackgroundWithBlock({
            result, error in
            if error == nil {
                if message.photo == nil {
                    self.messages.append(JSQMessage(senderId: message.user.objectId, senderDisplayName: message.user.name, date: message.createdAt, text: message.text))
                    self.finishReceivingMessage()
                } else {
                    message.photo!.getDataInBackgroundWithBlock({
                        result, error in
                        self.messages.append(JSQMessage(senderId: message.user.objectId, senderDisplayName: message.user.name, date: message.createdAt, media: JSQPhotoMediaItem(image: UIImage(data: result! ))))
                        self.finishReceivingMessage()
                    })
                }
                
            } else {
                self.loadMessage(id)
            }
        })
    }
    
    override func didPressSendButton(button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: NSDate) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        let message: Message = Message()
        message.user = PFUser.currentUser()!
        if event != nil {
            message.event = event!
        } else {
            message.group = group!
        }
        message.text = text
        message.saveInBackgroundWithBlock({
            result, error in
            if error == nil {
                self.messages.append(JSQMessage(senderId: message.user.objectId, senderDisplayName: message.user.name, date: message.createdAt, text: message.text))
                self.finishSendingMessageAnimated(true)
            } else {
                MessageToUser.showDefaultErrorMessage("Something went wrong.")
                self.finishSendingMessageAnimated(true)
            }
        })
        
    }
    
    override func collectionView(collectionView:JSQMessagesCollectionView, avatarImageDataForItemAtIndexPath indexPath:NSIndexPath) -> JSQMessageAvatarImageDataSource! {
        let message = self.messages[indexPath.item];
        return avatars[message.senderId]
    }
    
    override func collectionView(collectionView:JSQMessagesCollectionView, messageDataForItemAtIndexPath indexPath:NSIndexPath) -> JSQMessageData {
        return self.messages[indexPath.item];
    }
    
    override func collectionView(collectionView:JSQMessagesCollectionView, messageBubbleImageDataForItemAtIndexPath indexPath:NSIndexPath) -> JSQMessageBubbleImageDataSource {
        
        let message = messages[indexPath.item]
        if (message.senderId == self.senderId) {
            return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.orangeColor())
        }
        return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.grayColor())
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let pickedImage:UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
        let imageData = UIImagePNGRepresentation(pickedImage)
        let imageFile:PFFile = PFFile(data: imageData!)!
        
        
        let message: Message = Message()
        message.user = PFUser.currentUser()!
        if event != nil {
            message.event = event!
        } else {
            message.group = group!
        }
        message.photo = imageFile
        message.saveInBackgroundWithBlock({
            result, error in
            if error == nil {
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.messages.append(JSQMessage(senderId: message.user.objectId, senderDisplayName: message.user.name, date: message.createdAt, media: JSQPhotoMediaItem(image: pickedImage)))
                self.finishSendingMessageAnimated(true)
            } else {
                MessageToUser.showDefaultErrorMessage("Something went wrong.")
                self.finishSendingMessageAnimated(true)
            }
        })
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    //What to do if the image picker cancels.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
}
