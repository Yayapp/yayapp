//
//  ChooseCategoryCollectionViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 28.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class ChooseCategoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, GroupCreationDelegate {

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var publicButton: UIButton!
    @IBOutlet weak var privateButton: UIButton!
    @IBOutlet private weak var myGroupsButton: UIButton?
    
    @IBOutlet weak var allUnderline: UIView!
    @IBOutlet weak var publicUnderline: UIView!
    @IBOutlet weak var privateUnderline: UIView!
    @IBOutlet private var myGroupsUnderline: UIView?
  
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var categories: UICollectionView!
    
    @IBOutlet weak var filterContainer: UIImageView!

    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self

        return searchController
    }()
    var searchControllerText: String?
    var needsRefreshContent: Bool = false

    var categoriesData:[Category]! = []
    var privateCategoriesData:[Category]! = []
    var publicCategoriesData:[Category]! = []
    var myCategoriesData:[Category]! = []
    var selectedCategoriesData:[Category]! = []
    var selectedCategoryType: CategoryType = .All

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(ChooseCategoryViewController.handleUserLogout),
                                                         name: Constants.userDidLogoutNotification,
                                                         object: nil)

        categories.registerNib(CategoryCollectionViewCell.nib, forCellWithReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier)

        categories.delegate = self
        categories.dataSource = self

        loadContent()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if needsRefreshContent {
            loadContent()
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: Constants.userDidLogoutNotification,
                                                            object: nil)
    }

    //MARK: - Content Loading
    func loadContent() {
        ParseHelper.getCategories({ (categoriesList: [Category]?, error: NSError?) in
            guard let _ = ParseHelper.sharedInstance.currentUser where error == nil else {
                if let error = error {
                    MessageToUser.showDefaultErrorMessage(error.localizedDescription)
                }

                return
            }

            self.categoriesData = categoriesList!

            self.allAction(true)
        })
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if selectedCategoryType == CategoryType.All {
            return 2
        } else {
            return 1
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch (selectedCategoryType) {
            case .Private: return privateCategoriesData.count
            case .Public: return publicCategoriesData.count
            case .My: return myCategoriesData.count
            default: if section == 0{
                        return publicCategoriesData.count
                    } else {
                        return privateCategoriesData.count
                    }
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
            categoryHeader.name.text = indexPath.section == 0 ? NSLocalizedString("Public Groups", comment: "") : NSLocalizedString("Private Groups", comment: "")
        }

        return categoryHeader
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CategoryCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
    
        let category = categoryForIndexPath(indexPath)
        cell.name.text = category.name
        
        if let photoURLString = category.photoThumb.url,
            photoURL = NSURL(string: photoURLString) {
            cell.photo.sd_setImageWithURL(photoURL)
        }

        cell.switched.tag = indexPath.row;
        
        cell.onSwitchValueChanged = { [unowned self] isSwitcherOn in
            ParseHelper.changeStateOfCategory(self.categoryForIndexPath(indexPath),
                                              toJoined: isSwitcherOn,
                                              completion: nil)
        }
        
        if let currentUserID = ParseHelper.sharedInstance.currentUser?.objectId {
            cell.switched.on = category.attendeeIDs.contains(currentUserID)
            
            if let categoryOwnerId = category.owner?.objectId {
                cell.switched.enabled = categoryOwnerId != currentUserID
            }
        }

        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("details", sender: indexPath)
    }
    
    func configureCategories() {
        privateCategoriesData = categoriesData.filter({ $0.isPrivate })
        publicCategoriesData = categoriesData.filter({ !$0.isPrivate })
        myCategoriesData = categoriesData.filter({ (category) -> Bool in
            guard let owner = category.owner,
                currentUser = ParseHelper.sharedInstance.currentUser else {
                    return false
            }
            
            return owner.objectId == currentUser.objectId
        })
    }
    
    @IBAction func allAction(sender: AnyObject) {
        configureCategories()

        if let currentUserID = ParseHelper.sharedInstance.currentUser?.objectId {
            selectedCategoriesData = categoriesData.filter({ $0.attendeeIDs.contains(currentUserID) })
        }
        
        allUnderline.hidden = false
        publicUnderline.hidden = true
        privateUnderline.hidden = true
        myGroupsUnderline?.hidden = true
        selectedCategoryType = CategoryType.All
        allButton.setTitleColor(Color.PrimaryActiveColor, forState: UIControlState.Normal)
        publicButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        privateButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        myGroupsButton?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        categories.reloadData()
    }
    
    @IBAction func publicAction(sender: AnyObject) {
        allUnderline.hidden = true
        publicUnderline.hidden = false
        privateUnderline.hidden = true
        myGroupsUnderline?.hidden = true
        selectedCategoryType = CategoryType.Public
        allButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        publicButton.setTitleColor(Color.PrimaryActiveColor, forState: UIControlState.Normal)
        privateButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        myGroupsButton?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        categories.reloadData()
    }
    
    @IBAction func privateAction(sender: AnyObject) {
        allUnderline.hidden = true
        publicUnderline.hidden = true
        privateUnderline.hidden = false
        myGroupsUnderline?.hidden = true
        selectedCategoryType = CategoryType.Private
        allButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        publicButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        privateButton.setTitleColor(Color.PrimaryActiveColor, forState: UIControlState.Normal)
        myGroupsButton?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        categories.reloadData()
    }
    
    @IBAction func displayMyGroups(sender: UIButton) {
        allUnderline.hidden = true
        publicUnderline.hidden = true
        privateUnderline.hidden = true
        myGroupsUnderline?.hidden = false
        selectedCategoryType = CategoryType.My
        allButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        publicButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        privateButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        myGroupsButton?.setTitleColor(Color.PrimaryActiveColor, forState: .Normal)
        categories.reloadData()
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
        search(searchBar.text!)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func search(searchText:String){
        ParseHelper.searchCategories(searchText, block: {
            (categoriesList: [Category]?, error: NSError?) in
            if(error == nil) {
                self.categoriesData = categoriesList!
                self.allAction(true)
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
    }
    
    func groupCreated(group:Category) {
        categoriesData.append(group)
        allAction(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "details") {
            guard let vc = segue.destinationViewController as? GroupDetailsViewController,
                indexPath = sender as? NSIndexPath else {
                return
            }

            vc.group = categoryForIndexPath(indexPath)
            vc.selectedCategoriesData = selectedCategoriesData
            vc.updatedStatusInGroup = {
                self.categories.reloadItemsAtIndexPaths([indexPath])
            }
        } else if let vc = segue.destinationViewController as? CreateGroupViewController
            where segue.identifier == "create" {
            vc.delegate = self
        }
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
        needsRefreshContent = true
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
}

