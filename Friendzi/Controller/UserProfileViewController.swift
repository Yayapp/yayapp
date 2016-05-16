//
//  UserProfileViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 18.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

final class UserProfileViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,   UIPopoverPresentationControllerDelegate, TTGTextTagCollectionViewDelegate {
    
    @IBOutlet private weak var name: UILabel?
    @IBOutlet private weak var avatar: UIImageView?
    @IBOutlet private weak var eventsCount: UILabel?
    @IBOutlet private weak var about: UILabel?
    @IBOutlet private weak var rankIcon: UIImageView?
    @IBOutlet private weak var interestsCollection: TTGTextTagCollectionView?

    private let picker = UIImagePickerController()
    private var editdone: UIBarButtonItem?
    private var interestsData: [Category]! = []
    private var blocked = false

    var user: User?
    var userID: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(UserProfileViewController.handleUserLogout),
                                                         name: Constants.userDidLogoutNotification,
                                                         object: nil)
        picker.delegate = self

        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        interestsCollection?.enableTagSelection = false
        interestsCollection?.tagTextColor = UIColor.blackColor()
        interestsCollection?.tagSelectedTextColor = Color.PrimaryActiveColor
        interestsCollection?.tagSelectedBackgroundColor = UIColor.whiteColor()
        interestsCollection?.tagTextFont = UIFont.boldSystemFontOfSize(15)
        interestsCollection?.tagCornerRadius = 10
        interestsCollection?.tagSelectedCornerRadius = 0
        interestsCollection?.tagSelectedBorderWidth = 0
        interestsCollection?.tagBorderColor = UIColor.blackColor()
        interestsCollection?.horizontalSpacing = 12
        interestsCollection?.verticalSpacing = 12
        interestsCollection?.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if user == nil && userID == nil {
            user = ParseHelper.sharedInstance.currentUser
            setupUIWithUserInfo()
        } else if let userID = userID {
            SVProgressHUD.show()
            ParseHelper.fetchUser(userID, completion: { [weak self] (fetchedUser, error) in
                SVProgressHUD.dismiss()

                guard let user = fetchedUser where error == nil else {
                    MessageToUser.showDefaultErrorMessage(error?.localizedDescription)
                    return
                }

                self?.user = user
                self?.setupUIWithUserInfo()
            })
        } else {
            setupUIWithUserInfo()
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        interestsCollection?.removeAllTags()
        interestsCollection?.reload()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: Constants.userDidLogoutNotification,
                                                            object: nil)
    }

    func setupUIWithUserInfo() {
        name?.text = user?.name

        let isCurrentUser = ParseHelper.sharedInstance.currentUser?.objectId == user?.objectId

        if isCurrentUser {
            editdone = UIBarButtonItem(image:UIImage(named: "user_settings_ico"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(UserProfileViewController.settings(_:)))
            navigationItem.setRightBarButtonItem(editdone, animated: false)

            let tblView =  UIView(frame: CGRectZero)
            tableView.tableFooterView = tblView
            tableView.tableFooterView!.hidden = true
            title = "Profile"
        } else {
            navigationItem.title = user?.name
            guard let currentUser = ParseHelper.sharedInstance.currentUser, let user = user else {
                return
            }

            ParseHelper.countBlocks(currentUser, user: user, completion: { [weak self] count in
                self?.blocked = count > 0
                self?.editdone = UIBarButtonItem(image:UIImage(named: "reporticon"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(UserProfileViewController.blockUnblock))
                self?.navigationItem.setRightBarButtonItem(self?.editdone, animated: false)
                })
        }

        guard let user = user else {
            return
        }
        ParseHelper.getUpcomingPastEvents(user, upcoming: false, block: {
            result, error in
            if error == nil {
                let rank = Rank.getRank(result!.count)
                if let gender = self.user?.gender {
                    self.eventsCount?.text = rank.getString(gender)
                    self.rankIcon?.image = rank.getImage(gender)
                }
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
                self.interestsCollection?.addTags(names)
                self.interestsCollection?.setTagAtIndex(0, selected: true)
            }
        })

        if let avatarFile = user.avatar,
            photoURLString = avatarFile.url,
            photoURL = NSURL(string: photoURLString) {
            avatar?.layer.borderColor = UIColor.whiteColor().CGColor
            avatar?.sd_setImageWithURL(photoURL)
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
        about?.attributedText = myMutableString
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
    }
  
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return interestsCollection?.contentHeight ?? 0
        }

        about?.sizeToFit()

        return (about?.frame.height ?? 0) < 44 ? 44 : (about?.frame.height ?? 0) + 16
    }

    @IBAction func settings(sender: AnyObject) {
        performSegueWithIdentifier("settings", sender: nil)
    }
    
    func blockUnblock() {
        guard let currentUser = ParseHelper.sharedInstance.currentUser else {
            return
        }
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let reportViewController = mainStoryboard.instantiateViewControllerWithIdentifier(ReportViewController.storyboardID) as? ReportViewController {
            reportViewController.modalPresentationStyle = .OverCurrentContext
            reportViewController.modalTransitionStyle = .CrossDissolve
            
            if blocked {
                reportViewController.blockButtonTitle = NSLocalizedString("Unblock User", comment: "")
            }
            
            reportViewController.onBlock = {
                if self.blocked {
                    self.blocked = false
                    guard let user = self.user else {
                        return
                    }
                    ParseHelper.removeBlocks(currentUser, user: user, completion: { [weak self] error in
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
            }

            reportViewController.onReport = {
                let report = Report()
                report.reportedUser = self.user
                report.user = currentUser
                ParseHelper.saveObject(report, completion: { success, error in
                    
                })
            }

            self.presentViewController(reportViewController, animated: true, completion: nil)
        }
    }

    func textTagCollectionView(textTagCollectionView: TTGTextTagCollectionView!, updateContentHeight newContentHeight: CGFloat) {
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
    }

    //MARK: - Notification Handlers
    func handleUserLogout() {
        navigationController?.popToRootViewControllerAnimated(false)

        user = nil
        interestsData.removeAll()
        interestsCollection?.removeAllTags()
        interestsCollection?.reload()
        blocked = false
        name?.text = nil
        avatar?.image = nil
        eventsCount?.text = nil
        about?.text = nil
        rankIcon?.image = nil
        navigationItem.setRightBarButtonItem(nil, animated: false)

        tableView.reloadData()
    }
}
