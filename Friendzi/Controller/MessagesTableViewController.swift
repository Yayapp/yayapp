//
//  MessagesTableViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 06.10.15.
//  Copyright © 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

final class MessagesTableViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    static let storyboardID = "MessagesTableViewController"
    
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
        inputToolbar?.contentView?.textView?.placeHolder = "Message..."
        inputToolbar?.contentView?.textView?.layer.borderWidth = 1
        inputToolbar?.contentView?.textView?.layer.borderColor = Color.DefaultBorderColor.CGColor
        inputToolbar!.contentView?.textView?.layer.cornerRadius = 0
        inputToolbar?.contentView?.backgroundColor = Color.PrimaryBackgroundColor
//        if let width = inputToolbar?.contentView?.textView?.frame.width, let height = inputToolbar?.contentView?.frame.height {
//            inputToolbar?.contentView?.textView?.frame.size = CGSize(width: width,height: height)
//        }

        if event != nil {
            UIApplication.sharedApplication().applicationIconBadgeNumber -= Prefs.removeMessage(event!.objectId!)
            title = event?.name

        } else {
            UIApplication.sharedApplication().applicationIconBadgeNumber -= Prefs.removeMessage(group!.objectId!)
            title = group?.name
        }
        
        dateFormatter.dateFormat = "MM/dd/yy h:mm a"

        if event != nil {
            ParseHelper.fetchObject(event!, completion: {
            result, error in
            
            self.processAttendees(self.event!.attendeeIDs)
            
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
            ParseHelper.fetchObject(group!, completion: {
                result, error in
                
                self.processAttendees(self.group!.attendeeIDs)
                
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
        
        self.senderId = ParseHelper.sharedInstance.currentUser!.objectId;
        self.senderDisplayName = ParseHelper.sharedInstance.currentUser?.name
        self.collectionView!.collectionViewLayout.springinessEnabled = false
    }
    
    func processAttendees(attendeeIDs: [String]) {
        for attendeeID in attendeeIDs {
            ParseHelper.fetchUser(attendeeID, completion: { fetchedAttendee, error in
                guard let attendee = fetchedAttendee where error == nil else {
                    self.avatars[attendeeID] = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "upload_pic"), diameter: 45)
                    return
                }
                    attendee.getImage({
                        result in
                        guard let result = result else {
                            self.avatars[attendee.objectId!] = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "upload_pic"), diameter: 45)
                            return
                        }
                        
                        self.avatars[attendee.objectId!] = JSQMessagesAvatarImageFactory.avatarImageWithImage(result, diameter: 45)
                    })
            })
        }
    }
    
    func processMessages(result:[Message]){
        for (index,message) in result.enumerate() {
            if message.photo == nil {
                self.messages.append(JSQMessage(senderId: message.user.objectId, senderDisplayName: message.user.name, date: message.createdAt, text: message.text))

            } else {
                let media = JSQPhotoMediaItem()
                ParseHelper.getData(message.photo!, completion: {
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
        let alert = UIAlertController(title: "Choose Option".localized, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo".localized, style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction) in
            self.picker.allowsEditing = true
            self.picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.picker.cameraCaptureMode = .Photo
            self.picker.showsCameraControls = true;
            self.presentViewController(self.picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "From Library".localized, style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction) in
            self.picker.allowsEditing = true
            self.picker.sourceType = .PhotoLibrary
            self.presentViewController(self.picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func loadMessage(id:String) {
        let message = Message()
        message.objectId = id
        ParseHelper.fetchObject(message, completion: {
            result, error in
            if error == nil {
                if message.photo == nil {
                    self.messages.append(JSQMessage(senderId: message.user.objectId, senderDisplayName: message.user.name, date: message.createdAt, text: message.text))
                    self.finishReceivingMessage()
                } else {
                    ParseHelper.getData(message.photo!, completion: {
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
        message.user = ParseHelper.sharedInstance.currentUser!
        if event != nil {
            message.event = event!
        } else {
            message.group = group!
        }
        message.text = text

        ParseHelper.saveObject(message, completion: {
            result, error in
            if error == nil {
                self.messages.append(JSQMessage(senderId: message.user.objectId, senderDisplayName: message.user.name, date: message.createdAt, text: message.text))
                self.finishSendingMessageAnimated(true)
            } else {
                MessageToUser.showDefaultErrorMessage("Something went wrong.".localized)
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
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        let message = messages[indexPath.row]
        
        if message.isMediaMessage {
            let mediaItem = message.media
            
            if mediaItem.isKindOfClass(JSQPhotoMediaItem) {
                let photoItem = mediaItem as? JSQPhotoMediaItem
                presentImage(photoItem?.image)
            }
        }
    }
    
    func presentImage(image: UIImage?) {
        guard let imageViewController = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("ImageViewController") as? ImageViewController else {
            return
        }
        
        imageViewController.modalPresentationStyle = .OverCurrentContext
        imageViewController.backgroundImage = image
        imageViewController.imageTapped = {
            imageViewController.dismissViewControllerAnimated(true, completion: nil)
        }
        
        presentViewController(imageViewController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let pickedImage:UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
        let imageData = UIImagePNGRepresentation(pickedImage)
        let imageFile = File(data: imageData!)!

        let message: Message = Message()
        message.user = ParseHelper.sharedInstance.currentUser!
        if event != nil {
            message.event = event!
        } else {
            message.group = group!
        }

        message.photo = imageFile
        ParseHelper.saveObject(message, completion: {
            result, error in
            if error == nil {
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.messages.append(JSQMessage(senderId: message.user.objectId, senderDisplayName: message.user.name, date: message.createdAt, media: JSQPhotoMediaItem(image: pickedImage)))
                self.finishSendingMessageAnimated(true)
            } else {
                MessageToUser.showDefaultErrorMessage("Something went wrong.".localized)
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
        let alertVC = UIAlertController(title: "No Camera".localized,
                                        message: "Sorry, this device has no camera".localized,
                                        preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK".localized, style:.Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
}
