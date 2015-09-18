import UIKit

class ConversationViewController: ATLConversationViewController, ATLConversationViewControllerDataSource, ATLConversationViewControllerDelegate {
    var dateFormatter: NSDateFormatter = NSDateFormatter()
    var usersArray: NSArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        title = conversation.metadata["name"] as! String!
//        self.addressBarController.delegate = self
        let back = UIBarButtonItem(image:UIImage(named: "notifications_backarrow"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("backButtonTapped:"))
        back.tintColor = UIColor(red:CGFloat(3/255.0), green:CGFloat(118/255.0), blue:CGFloat(114/255.0), alpha: 1)
        self.navigationItem.setLeftBarButtonItem(back, animated: false)
        // Setup the dateformatter used by the dataSource.
        self.dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        self.dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        self.configureUI()
    }
   
    
    // MARK - UI Configuration methods
    
    func configureUI() {
        ATLOutgoingMessageCollectionViewCell.appearance().messageTextColor = UIColor.whiteColor()
        shouldDisplayAvatarItemForOneOtherParticipant = true
        ATLAvatarImageView.appearance().avatarImageViewDiameter = 40
    }
    
    func shouldDisplayAvatarItem() ->Bool {
        return true
    }
    
    func conversationViewController(viewController: ATLConversationViewController, didSendMessage message: LYRMessage) {
//        println("Message sent!")
    }
    
    func conversationViewController(viewController: ATLConversationViewController, didFailSendingMessage message: LYRMessage, error: NSError?) {
        print("Message failed to sent with error: \(error)")
    }
    
    func conversationViewController(viewController: ATLConversationViewController, didSelectMessage message: LYRMessage) {
        print("Message selected")
    }
    
    // MARK - ATLConversationViewControllerDataSource methods
    
    func conversationViewController(conversationViewController: ATLConversationViewController, participantForIdentifier participantIdentifier: String) -> ATLParticipant? {
        if (participantIdentifier == PFUser.currentUser()!.objectId!) {
            return PFUser.currentUser()!
        }
        let user: PFUser? = UserManager.sharedManager.cachedUserForUserID(participantIdentifier)
        if (user == nil) {
            UserManager.sharedManager.queryAndCacheUsersWithIDs([participantIdentifier]) { (participants: NSArray?, error: NSError?) -> Void in
                if (participants?.count > 0 && error == nil) {
//                    self.addressBarController.reloadView()
                    // TODO: Need a good way to refresh all the messages for the refreshed participants...
                    self.reloadCellsForMessagesSentByParticipantWithIdentifier(participantIdentifier)
                } else {
                    print("Error querying for users: \(error)")
                }
            }
        }
        return user
    }
    
    func conversationViewController(conversationViewController: ATLConversationViewController, attributedStringForDisplayOfDate date: NSDate) -> NSAttributedString? {
        let attributes: NSDictionary = [ NSFontAttributeName : UIFont.systemFontOfSize(14), NSForegroundColorAttributeName : UIColor.grayColor() ]
        return NSAttributedString(string: self.dateFormatter.stringFromDate(date), attributes: attributes as? [String : AnyObject])
    }
    
    func conversationViewController(conversationViewController: ATLConversationViewController, attributedStringForDisplayOfRecipientStatus recipientStatus: [NSObject:AnyObject]) -> NSAttributedString? {
        if (recipientStatus.count == 0) {
            return nil
        }
        let mergedStatuses: NSMutableAttributedString = NSMutableAttributedString()
        
        let recipientStatusDict = recipientStatus as NSDictionary
        let allKeys = recipientStatusDict.allKeys as NSArray
        allKeys.enumerateObjectsUsingBlock { participant, _, _ in
            let participantAsString = participant as! String
            if (participantAsString == self.layerClient.authenticatedUserID) {
                return
            }
            
            let checkmark: String = "✔︎"
            var textColor: UIColor = UIColor.lightGrayColor()
            let status: LYRRecipientStatus! = LYRRecipientStatus(rawValue: recipientStatusDict[participantAsString]!.unsignedIntegerValue)
            switch status! {
            case .Sent:
                textColor = UIColor.lightGrayColor()
            case .Delivered:
                textColor = UIColor.orangeColor()
            case .Read:
                textColor = UIColor.greenColor()
            default:
                textColor = UIColor.lightGrayColor()
            }
            let statusString: NSAttributedString = NSAttributedString(string: checkmark, attributes: [NSForegroundColorAttributeName: textColor])
            mergedStatuses.appendAttributedString(statusString)
        }
        return mergedStatuses;
    }
    
 
    func messageForMessageParts(parts: [AnyObject], MIMEType: String, pushText: String?) -> LYRMessage? {
        let senderName: String = PFUser.currentUser()!.objectForKey("name") as! String
        let conversationName: String = conversation.metadata["name"] as! String
        var completePushText: String
        if pushText == nil {
            if MIMEType == ATLMIMETypeImageGIF {
                completePushText = "\(senderName) sent you a GIF."
            }
            else {
                if MIMEType == ATLMIMETypeImagePNG || MIMEType == ATLMIMETypeImageJPEG {
                    completePushText = "\(senderName) sent you a photo."
                }
                else {
                    if MIMEType == ATLMIMETypeLocation {
                        completePushText = "\(senderName) sent you a location."
                    }
                    else {
                        completePushText = "\(senderName) sent you a message."
                    }
                }
            }
        }
        else {
            completePushText = "\(senderName) in  \"\(conversationName)\" event topic: \(pushText!)"
        }
        let pushOptions: [NSObject: AnyObject] = [LYRMessageOptionsPushNotificationAlertKey: completePushText, LYRMessageOptionsPushNotificationSoundNameKey: "layerbell.caf"]
        var message: LYRMessage
        do {
            message =  try self.layerClient.newMessageWithParts(parts, options: pushOptions)
        } catch {
            return nil
        }
        
        return message
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}