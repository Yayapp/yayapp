//
//  UserProfileViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 18.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class UserProfileViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,   UIPopoverPresentationControllerDelegate {

    let picker = UIImagePickerController()
    var user: User!
    var editdone:UIBarButtonItem!
    var interestsData:[Category]!=[]
    var blocked = false
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var eventsCount: UILabel!
    
    @IBOutlet weak var about: UILabel!
    @IBOutlet weak var rankIcon: UIImageView!
    @IBOutlet weak var blockUnblock: UIButton!
    
    @IBOutlet weak var interestsCollection: TTGTextTagCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
//        interestsCollection.scrollEnabled = false
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        interestsCollection.enableTagSelection = false
        interestsCollection.tagTextColor = UIColor.blackColor()
        interestsCollection.tagSelectedTextColor = Color.PrimaryActiveColor
        interestsCollection.tagSelectedBackgroundColor = UIColor.whiteColor()
        interestsCollection.tagTextFont = UIFont.boldSystemFontOfSize(15)
        interestsCollection.tagCornerRadius = 10
        interestsCollection.tagSelectedCornerRadius = 0
        interestsCollection.tagSelectedBorderWidth = 0
        interestsCollection.tagBorderColor = UIColor.blackColor()
        
        if(user == nil){
            user = ParseHelper.sharedInstance.currentUser
        }
        
        
//        interestsCollection.dataSource = self
//        interestsCollection.delegate = self
        
        name.text = user.name
        
        if(PFUser.currentUser()?.objectId == user.objectId) {
            
            editdone = UIBarButtonItem(image:UIImage(named: "user_settings_ico"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("settings:"))
            
            self.navigationItem.setRightBarButtonItem(editdone, animated: false)
            
            let tblView =  UIView(frame: CGRectZero)
            tableView.tableFooterView = tblView
            tableView.tableFooterView!.hidden = true
            title = "Profile"
        } else {
            title = user.name
            ParseHelper.countBlocks(ParseHelper.sharedInstance.currentUser!, user: user, completion: { [weak self] count in
                self?.blocked = count > 0
                self?.blockUnblock.hidden = false
                })
        }
        
        
        ParseHelper.getUpcomingPastEvents(user, upcoming: false, block: {
            result, error in
            if error == nil {
                let rank = Rank.getRank(result!.count)
                self.eventsCount.text = rank.getString(self.user.gender!)
                self.rankIcon.image = rank.getImage(self.user.gender!)
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
        
        ParseHelper.getUserCategories(user, block: {
            categories, error in
            
            if error == nil {
                self.interestsData = categories
                var names:[String] = []
                names.append("Groups:")
                for (_, category) in (categories?.enumerate())! {
                    names.append(" \(category.name) ")
                }
                self.interestsCollection.addTags(names)
                self.interestsCollection.setTagAtIndex(0, selected: true)
//                self.interestsCollection.reloadData()
//                self.interestsCollection.frame.size = CGSize(width: self.interestsCollection.frame.width, height: self.interestsCollection.contentSize.height + 44)
//                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
            }
        })

        if let avatarFile = user.avatar,
            photoURLString = avatarFile.url,
            photoURL = NSURL(string: photoURLString) {
            avatar.layer.borderColor = UIColor.whiteColor().CGColor
            avatar.sd_setImageWithURL(photoURL)
        }


        if user.about != nil {
            setAboutMe(user.about!)
        }
    }

    func setAboutMe(text:String){
        let font15 = UIFont.boldSystemFontOfSize(15)
        let font11 = UIFont.systemFontOfSize(15)
        let range = NSRange(location: " Bio: ".characters.count, length: text.characters.count)
        let myMutableString = NSMutableAttributedString(string: " Bio: "+text, attributes: [NSFontAttributeName:font15])
        myMutableString.addAttribute(NSFontAttributeName, value: font11, range: range)
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor() , range: range)
        about.attributedText = myMutableString
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
    }
  
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 1 {
            interestsCollection.sizeToFit()
            if interestsCollection.frame.height<44 {
                return 44
            } else {
                return interestsCollection.frame.height + interestsCollection.frame.height*50/100
            }
        } else if indexPath.row == 0 {
            about.sizeToFit()
            if about.frame.height<44 {
                return 44
            } else {
                return about.frame.height + 16
            }
        } else {
            return 44
        }
    }
      
    @IBAction func settings(sender: AnyObject) {
        performSegueWithIdentifier("settings", sender: nil)
    }
    
    @IBAction func blockUnblock(sender: AnyObject) {
        guard let currentUser = ParseHelper.sharedInstance.currentUser else {
            return
        }

        let blockUserAlert = UIAlertController(title: NSLocalizedString("Block User", comment: ""),
                                               message: NSLocalizedString("You are about to block this user. Are you sure?", comment: ""),
                                               preferredStyle: .Alert)

        blockUserAlert.addAction(UIAlertAction(title: blocked ? NSLocalizedString("Unblock User", comment: "") : NSLocalizedString("Block User", comment: ""),
            style: .Default,
            handler: { [unowned self] (_) in
                if self.blocked {
                    self.blocked = false

                    ParseHelper.removeBlocks(currentUser, user: self.user, completion: { [weak self] error in
                        if let _ = self where error != nil {
                            MessageToUser.showDefaultErrorMessage(error?.localizedDescription)
                        }})
                    
                    return
                }

                let block = Block()
                block.owner = currentUser
                block.user = self.user
                self.blocked = !self.blocked
                ParseHelper.saveObject(block, completion: { [weak self] (_, error) in
                    if let weakSelf = self where error != nil {
                        weakSelf.blocked = !weakSelf.blocked
                        MessageToUser.showDefaultErrorMessage(NSLocalizedString("Something went wrong.", comment: ""))
                    }
                })
            }))
        blockUserAlert.addAction(UIAlertAction(title: NSLocalizedString("Flag User", comment: ""),
            style: .Default,
            handler: { [unowned self] (_) in
                let report = Report()
                report.reportedUser = self.user
                report.user = currentUser
                report.saveInBackground()
        }))
        blockUserAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
            style: .Cancel,
            handler: nil))

        presentViewController(blockUserAlert, animated: true, completion: nil)
    }
}
