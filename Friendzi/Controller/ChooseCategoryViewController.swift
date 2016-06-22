//
//  ChooseCategoryCollectionViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 28.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

enum CategoryType {
    case All, Private, Public, My
}

final class ChooseCategoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, GroupCreationDelegate, GroupChangeDelegate {

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet private weak var allButton: UIButton?
    @IBOutlet private weak var publicButton: UIButton?
    @IBOutlet private weak var privateButton: UIButton?
    @IBOutlet private weak var myGroupsButton: UIButton?
    @IBOutlet private weak var allUnderline: UIView?
    @IBOutlet private weak var publicUnderline: UIView?
    @IBOutlet private weak var privateUnderline: UIView?
    @IBOutlet private weak var myGroupsUnderline: UIView?
    @IBOutlet private weak var navBar: UINavigationBar?
    @IBOutlet private weak var categories: UICollectionView?
    @IBOutlet private weak var filterContainer: UIImageView?

    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self

        return searchController
    }()

    var searchControllerText: String?
    var userDidLogout = false

    var categoriesData: [Category]! = []
    var privateCategoriesData: [Category]! = []
    var publicCategoriesData: [Category]! = []
    var myCategoriesData: [Category]! = []
    var selectedCategoriesData: [Category]! = []
    var selectedCategoryType: CategoryType = .All

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(ChooseCategoryViewController.handleUserLogout),
                                                         name: Constants.userDidLogoutNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(ChooseCategoryViewController.handleGroupPendingStatusChange),
                                                         name: Constants.groupPendingStatusChangedNotification,
                                                         object: nil)

        categories?.registerNib(CategoryCollectionViewCell.nib, forCellWithReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier)

        categories?.delegate = self
        categories?.dataSource = self

        loadContent(needsSelectFirstTab: true)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let popoverController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(PopoverViewController.storyboardID) as? PopoverViewController,
            let controllersCount = tabBarController?.viewControllers?.count
            where DataProxy.sharedInstance.needsShowGroupsTabHint {
            let elementWidth = CGRectGetWidth(view.bounds) / CGFloat(controllersCount)

            popoverController.arrowViewLeadingSpace = elementWidth * 2 - (elementWidth / 2) - 20
            popoverController.text = "Request to join group that interest you. Don't see anything that you're into?  Then, create your own private group!".localized
            popoverController.submitButtonTitle = "Choose Group (2/4)".localized
            popoverController.skipButtonHidden = true
            popoverController.onSubmitPressed = { [weak self] in
                self?.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
            }

            DataProxy.sharedInstance.needsShowGroupsTabHint = false
            presentViewController(popoverController, animated: false, completion: nil)
        }

        loadContent(needsSelectFirstTab: userDidLogout)
        userDidLogout = false
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    //MARK: - Content Loading
    func loadContent(needsSelectFirstTab needsSelectFirstTab: Bool) {
        ParseHelper.getCategories({ [weak self] categoriesList, error in
            guard let _ = ParseHelper.sharedInstance.currentUser where error == nil else {
                if let error = error {
                    MessageToUser.showDefaultErrorMessage(error.localizedDescription)
                }

                return
            }

            self?.categoriesData = categoriesList!

            if needsSelectFirstTab {
                self?.allAction(true)
            } else {
                self?.categories?.reloadData()
            }
            })
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if selectedCategoryType == .All {
            return 2
        } else {
            return 1
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch selectedCategoryType {
        case .Private:
            return privateCategoriesData.count

        case .Public:
            return publicCategoriesData.count

        case .My:
            return myCategoriesData.count

        default:
            return section == 0 ? publicCategoriesData.count : privateCategoriesData.count
        }
    }

    internal func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                                                                           withReuseIdentifier: CategoryHeader.reuseIdentifier,
                                                                        forIndexPath: indexPath)
        guard let categoryHeader = header as? CategoryHeader else {
            return header
        }

        if selectedCategoryType == .All {
            categoryHeader.name = indexPath.section == 0 ? "Public Groups".localized : "Private Groups".localized
        }

        return categoryHeader
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CategoryCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }

        let category = categoryForIndexPath(indexPath)
        cell.name?.text = category.name

        if let photoURLString = category.photoThumb.url,
            photoURL = NSURL(string: photoURLString) {
            cell.photo?.sd_setImageWithURL(photoURL)
        }

        cell.switched?.tag = indexPath.row
        cell.onSwitchValueChanged = { [unowned self] isSwitcherOn in
            guard let blurryAlertViewController = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as? BlurryAlertViewController else {
                return
            }

            cell.switched?.onTintColor = category.isPrivate ? .appOrangeColor() : .appGreenColor()

            ParseHelper.changeStateOfCategory(category,
                                              toJoined: isSwitcherOn,
                                              completion: nil)

            if category.isPrivate && isSwitcherOn {
                blurryAlertViewController.action = BlurryAlertViewController.BUTTON_OK
                blurryAlertViewController.modalPresentationStyle = .OverCurrentContext

                blurryAlertViewController.aboutText = "Your request has been sent.".localized
                blurryAlertViewController.messageText = "We will notify you of the outcome.".localized

                self.presentViewController(blurryAlertViewController, animated: true, completion: nil)
            }
        }

        if let currentUserID = ParseHelper.sharedInstance.currentUser?.objectId,
            let categoryOwnerId = category.owner?.objectId,
            categoryID = category.objectId {
            let isSwitchOn = category.attendeeIDs.contains(currentUserID) || ParseHelper.sharedInstance.currentUser?.pendingGroupIDs.contains(categoryID) == true

            cell.switched?.on = isSwitchOn

            if categoryOwnerId == currentUserID || !category.isPrivate {
                cell.switched?.onTintColor = .appGreenColor()
            } else {
                if isSwitchOn {
                    cell.switched?.onTintColor = ParseHelper.sharedInstance.currentUser?.pendingGroupIDs.contains(categoryID) == true ? .appOrangeColor() : .appGreenColor()

                } else {
                    cell.switched?.onTintColor = category.isPrivate ? .appOrangeColor() : .appGreenColor()
                }
            }

            cell.switched?.enabled = categoryOwnerId != currentUserID
        }

        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("details", sender: indexPath)
    }

    func configureCategories() {
        privateCategoriesData = categoriesData.filter({ $0.isPrivate })
        publicCategoriesData = categoriesData.filter({ !$0.isPrivate })
        myCategoriesData = categoriesData.filter({ category -> Bool in
            guard let owner = category.owner, currentUser = ParseHelper.sharedInstance.currentUser else {
                    return false
            }

            return owner == currentUser
        })
    }

    @IBAction func allAction(sender: AnyObject) {
        configureCategories()

        if let currentUserID = ParseHelper.sharedInstance.currentUser?.objectId {
            selectedCategoriesData = categoriesData.filter({ $0.attendeeIDs.contains(currentUserID) })
        }

        allUnderline?.hidden = false
        publicUnderline?.hidden = true
        privateUnderline?.hidden = true
        myGroupsUnderline?.hidden = true
        selectedCategoryType = .All
        allButton?.setTitleColor(Color.PrimaryActiveColor, forState: UIControlState.Normal)
        publicButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        privateButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        myGroupsButton?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        categories?.reloadData()
    }

    @IBAction func publicAction(sender: AnyObject) {
        allUnderline?.hidden = true
        publicUnderline?.hidden = false
        privateUnderline?.hidden = true
        myGroupsUnderline?.hidden = true
        selectedCategoryType = .Public
        allButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        publicButton?.setTitleColor(Color.PrimaryActiveColor, forState: UIControlState.Normal)
        privateButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        myGroupsButton?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        categories?.reloadData()
    }

    @IBAction func privateAction(sender: AnyObject) {
        allUnderline?.hidden = true
        publicUnderline?.hidden = true
        privateUnderline?.hidden = false
        myGroupsUnderline?.hidden = true
        selectedCategoryType = .Private
        allButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        publicButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        privateButton?.setTitleColor(Color.PrimaryActiveColor, forState: UIControlState.Normal)
        myGroupsButton?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        categories?.reloadData()
    }

    @IBAction func displayMyGroups(sender: UIButton) {
        allUnderline?.hidden = true
        publicUnderline?.hidden = true
        privateUnderline?.hidden = true
        myGroupsUnderline?.hidden = false
        selectedCategoryType = .My
        allButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        publicButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        privateButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        myGroupsButton?.setTitleColor(Color.PrimaryActiveColor, forState: .Normal)
        categories?.reloadData()
    }

    @IBAction func searchAction(sender: AnyObject) {
        searchController.searchBar.text = searchControllerText
        presentViewController(searchController, animated: true, completion: nil)
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchControllerText = searchText
        search(searchText)
    }

    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if let text = searchBar.text {
            search(text)
        }
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func search(searchText: String){
        ParseHelper.searchCategories(searchText, block: { categoriesList, error in
            guard let categoriesList = categoriesList else {
                if let error = error {
                    MessageToUser.showDefaultErrorMessage(error.localizedDescription)
                }
                return
            }

            self.categoriesData = categoriesList
            self.allAction(true)
        })
    }

    func groupCreated(group: Category) {
        guard let shareItemVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(ShareItemViewController.storyboardID) as? ShareItemViewController else {
            return
        }

        shareItemVC.modalPresentationStyle = .OverCurrentContext
        shareItemVC.modalTransitionStyle = .CrossDissolve
        shareItemVC.item = group
        shareItemVC.onCancelPressed = { [weak self] in
            self?.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
            self?.tabBarController?.selectedIndex = 0
        }

        self.presentViewController(shareItemVC, animated: true, completion: nil)
        categoriesData.append(group)
        allAction(true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "details") {
            guard let vc = segue.destinationViewController as? GroupDetailsViewController, indexPath = sender as? NSIndexPath else {
                return
            }

            vc.delegate = self
            vc.group = categoryForIndexPath(indexPath)
            vc.selectedCategoriesData = selectedCategoriesData
            vc.updatedStatusInGroup = {
                self.categories?.reloadItemsAtIndexPaths([indexPath])
            }
        } else if let vc = segue.destinationViewController as? CreateGroupViewController where segue.identifier == "create" {
            vc.delegate = self
        }
    }

    //MARK: - GroupChangeDelegate
    func groupChanged(group: Category) {
        loadContent(needsSelectFirstTab: false)
    }

    func groupRemoved(group: Category) {
        loadContent(needsSelectFirstTab: false)
    }

    //MARK: - Helpers
    func categoryForIndexPath(indexPath: NSIndexPath) -> Category {
        var category: Category

        switch (selectedCategoryType) {
        case .Private:
            category = privateCategoriesData[indexPath.row]
        case .Public:
            category = publicCategoriesData[indexPath.row]
        case .My:
            category = myCategoriesData[indexPath.row]
        default:
            category = indexPath.section == 0 ? publicCategoriesData[indexPath.row] : privateCategoriesData[indexPath.row]
        }

        return category
    }

    //MARK: - Notification Handlers
    func handleUserLogout() {
        userDidLogout = true
        navigationController?.popToRootViewControllerAnimated(false)

        searchController.active = false
        searchControllerText = nil

        categoriesData.removeAll()
        privateCategoriesData.removeAll()
        publicCategoriesData.removeAll()
        myCategoriesData.removeAll()
        selectedCategoriesData.removeAll()
        selectedCategoryType = .All
        
        allAction(true)
    }
    
    func handleGroupPendingStatusChange() {
        loadContent(needsSelectFirstTab: false)
    }
}

