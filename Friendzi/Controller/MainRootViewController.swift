//
//  MainViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit
import MessageUI

final class MainRootViewController: UIViewController, MFMailComposeViewControllerDelegate, EventChangeDelegate, ListEventsDelegate {

    @IBOutlet weak var todayButton: UIButton?
    @IBOutlet weak var tomorrowButton: UIButton?
    @IBOutlet weak var thisWeekButton: UIButton?
    @IBOutlet weak var todayUnderline: UIView?
    @IBOutlet weak var tomorrowUnderline: UIView?
    @IBOutlet weak var thisWeekUnderline: UIView?
    @IBOutlet weak var container: UIView?
    @IBOutlet weak var createEvent: UIButton?

    private var rightSwitchBarButtonItem: UIBarButtonItem?
    private var currentVC:EventsViewController!
    private var isMapView = false
    private var chosenCategories:[Category] = []
    private var selectedSegment: Int = 0
    private var eventsData:[Event]! = []

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(MainRootViewController.handleUserLogout),
                                                         name: Constants.userDidLogoutNotification,
                                                         object: nil)

        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = UIImage(named: "logo") ?? UIImage()
        self.navigationItem.titleView = imageView

        guard let _ = ParseHelper.sharedInstance.currentUser else {
            return
        }

        handleTableViewForTodayEvents()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        segmentChanged()
        if Prefs.getPref(Prefs.tut) == false {
            Prefs.setPref(Prefs.tut)
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: Constants.userDidLogoutNotification,
                                                            object: nil)
    }

    func segmentChanged() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let mapEventsVC = mainStoryboard.instantiateViewControllerWithIdentifier("MapEventsViewController") as? MapEventsViewController,
            listEventsVC = mainStoryboard.instantiateViewControllerWithIdentifier("ListEventsViewController") as? ListEventsViewController else {
                return
        }

        let vc = isMapView ? mapEventsVC : listEventsVC

        vc.delegate = self
        if(selectedSegment == 0) {
            ParseHelper.getTodayEvents(ParseHelper.sharedInstance.currentUser, categories: chosenCategories, block: {
                (eventsList:[Event]?, error:NSError?) in
                if(error == nil) {
                    vc.reloadAll(eventsList!)
                } else {
                    MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                }
            })
        } else if (selectedSegment == 1) {
            ParseHelper.getTomorrowEvents(ParseHelper.sharedInstance.currentUser, categories: chosenCategories, block: {
                (eventsList:[Event]?, error:NSError?) in
                if(error == nil) {
                    vc.reloadAll(eventsList!)
                } else {
                    MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                }
            })
        } else {
            ParseHelper.getLaterEvents(ParseHelper.sharedInstance.currentUser, categories: chosenCategories, block: {
                (eventsList:[Event]?, error:NSError?) in
                if(error == nil) {
                    vc.reloadAll(eventsList!)
                } else {
                    MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                }
            })
        }

        updateActiveViewController(vc)
    }

    @IBAction func createEvent(sender: AnyObject) {
        if ParseHelper.sharedInstance.currentUser != nil {
            guard let vc = UIStoryboard.createEventTab()?.instantiateViewControllerWithIdentifier("CreateEventViewController") as? CreateEventViewController else {
                return
            }

            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        } else {
            guard let vc = UIStoryboard.auth()?.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController else {
                return
            }

            presentViewController(vc, animated: true, completion: nil)
        }
    }

    //MARK: - EventChangeDelegate
    func eventCreated(event:Event) {
        segmentChanged()
    }

    func eventChanged(event: Event) {
    }

    func eventRemoved(event: Event) {
    }

    func showMessages() {
        guard let controller: ConversationsTableViewController = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("ConversationsTableViewController") as? ConversationsTableViewController else {
            return
        }

        navigationController?.pushViewController(controller, animated: true)
    }

    func showProfile(){
        guard let vc = UIStoryboard.profileTab()?.instantiateViewControllerWithIdentifier("UserProfileViewController") as? UserProfileViewController else {
            return
        }

        vc.user = ParseHelper.sharedInstance.currentUser
        navigationController?.pushViewController(vc, animated: true)
    }

    func showInvite(){
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = self.configuredMailComposeViewController()
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }

    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let userName = ParseHelper.sharedInstance.currentUser?.name
        let emailTitle = "\(userName) invited you to Friendzi app"
        let messageBody = "\(userName) has invited you to join Friendzi. \n\nhttp://friendzi.io/"
        let mailComposerVC = MFMailComposeViewController()

        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setSubject(emailTitle)
        mailComposerVC.setMessageBody(messageBody, isHTML: false)
        return mailComposerVC
    }

    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email".localized,
                                             message: "Your device could not send e-mail.  Please check e-mail configuration and try again.".localized,
                                             delegate: self,
                                             cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }

    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    func showTerms(){
        guard let vc = UIStoryboard.profileTab()?.instantiateViewControllerWithIdentifier("TermsController") as? TermsController else {
            return
        }

        presentViewController(vc, animated: true, completion: nil)
    }

    func showPrivacy(){
        guard let vc = UIStoryboard.profileTab()?.instantiateViewControllerWithIdentifier("PrivacyPolicyController") as? PrivacyPolicyController else {
            return
        }

        presentViewController(vc, animated: true, completion: nil)
    }

    func madeEventChoice(event: Event) {
        guard let eventDetailsVC = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("EventDetailsViewController") as? EventDetailsViewController else {
            return
        }

        eventDetailsVC.event = event
        eventDetailsVC.delegate = currentVC
        navigationController?.pushViewController(eventDetailsVC, animated: true)
    }

    func madeCategoryChoice(categories: [Category]) {
        chosenCategories = categories
        segmentChanged()
    }

    func removeInactiveViewController(inactiveViewController: UIViewController?) {
        if let inActiveVC = inactiveViewController {
            // call before removing child view controller's view from hierarchy
            inActiveVC.willMoveToParentViewController(nil)
            
            inActiveVC.view.removeFromSuperview()
            
            // call after removing child view controller's view from hierarchy
            inActiveVC.removeFromParentViewController()
        }
    }

    func updateActiveViewController(activeViewController: EventsViewController!) {
        if activeViewController != nil {
            addChildViewController(activeViewController!)
            activeViewController?.view.frame = container?.bounds ?? CGRect.zero
            container?.addSubview(activeViewController!.view)
            activeViewController!.didMoveToParentViewController(self)
            
        }
        removeInactiveViewController(currentVC)
        currentVC = activeViewController
    }

    @IBAction func switchTapped(sender: AnyObject) {
        isMapView = !isMapView
        if isMapView {
            navigationItem.rightBarButtonItem!.image = UIImage(named: "listico")
        } else {
            navigationItem.rightBarButtonItem!.image = UIImage(named: "mapmarkerico")
        }
        segmentChanged()
    }

    //MARK: - Notification Handlers
    func handleUserLogout() {
        navigationController?.popToRootViewControllerAnimated(false)
        
        isMapView = false
        eventsData.removeAll()
        chosenCategories.removeAll()
        handleTableViewForTodayEvents()
    }
}

private extension MainRootViewController {
    //MARK:- Action Buttons
    @IBAction func todayEventsButtonTapped(sender: UIButton) {
        handleTableViewForTodayEvents()
    }

    @IBAction func tomorrow(sender: UIButton) {
        handleTableViewForTomorrowEvents()
    }

    @IBAction func thisWeek(sender: UIButton) {
        handleTableViewForLaterEvents()
    }
}

private extension MainRootViewController {
    //MARK:- UI Helpers
    //TODO:- The tab switching process would be better handled if the logic its embeded within an enum. Improves readability and logic handling.
    func handleTableViewForTodayEvents() {
        selectedSegment = 0
        todayUnderline?.hidden = false
        tomorrowUnderline?.hidden = true
        thisWeekUnderline?.hidden = true
        todayButton?.setTitleColor(Color.PrimaryActiveColor, forState: .Normal)
        tomorrowButton?.setTitleColor(.blackColor(), forState: .Normal)
        thisWeekButton?.setTitleColor(.blackColor(), forState: .Normal)
        segmentChanged()
    }

    func handleTableViewForTomorrowEvents() {
        selectedSegment = 1
        todayUnderline?.hidden = true
        tomorrowUnderline?.hidden = false
        thisWeekUnderline?.hidden = true
        todayButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        tomorrowButton?.setTitleColor(Color.PrimaryActiveColor, forState: UIControlState.Normal)
        thisWeekButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        segmentChanged()
    }

    func handleTableViewForLaterEvents() {
        selectedSegment = 2
        todayUnderline?.hidden = true
        tomorrowUnderline?.hidden = true
        thisWeekUnderline?.hidden = false
        todayButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        tomorrowButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        thisWeekButton?.setTitleColor(Color.PrimaryActiveColor, forState: UIControlState.Normal)
        segmentChanged()
    }
}
