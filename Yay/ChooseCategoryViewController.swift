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
    
    @IBOutlet weak var allUnderline: UIView!
    @IBOutlet weak var publicUnderline: UIView!
    @IBOutlet weak var privateUnderline: UIView!
  
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var categories: UICollectionView!
    
    @IBOutlet weak var filterContainer: UIImageView!

    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self

        return searchController
    }()
    var searchControllerText: String?

    var categoriesData:[Category]! = []
    var privateCategoriesData:[Category]! = []
    var publicCategoriesData:[Category]! = []
    var selectedCategoriesData:[Category]! = []
    var selectedCategoryType: CategoryType = .All

    override func viewDidLoad() {
        super.viewDidLoad()

        categories.registerNib(CategoryCollectionViewCell.nib, forCellWithReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier)

        categories.delegate = self
        categories.dataSource = self

        ParseHelper.getCategories({ (categoriesList: [Category]?, error: NSError?) in
            guard let currentUser = ParseHelper.sharedInstance.currentUser where error == nil else {
                if let error = error {
                    MessageToUser.showDefaultErrorMessage(error.localizedDescription)
                }

                return
            }

            self.categoriesData = categoriesList!
            self.privateCategoriesData = self.categoriesData.filter({ $0.isPrivate })
            self.publicCategoriesData = self.categoriesData.filter({ !$0.isPrivate })
            self.selectedCategoriesData = self.categoriesData.filter({ $0.attendees.contains(currentUser) })
            self.allAction(true)
        })
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if selectedCategoryType == CategoryType.All{
            return 2
        } else {
            return 1
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch (selectedCategoryType) {
            case .Private: return privateCategoriesData.count
            case .Public: return publicCategoriesData.count
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
    
        var category:Category

        switch (selectedCategoryType) {
        case .Private:
            category = privateCategoriesData[indexPath.row]
        case .Public:
            category = publicCategoriesData[indexPath.row]
        default:
            if(indexPath.section == 0) {
                category = publicCategoriesData[indexPath.row]
            } else {
                category = privateCategoriesData[indexPath.row]
            }
        }

        cell.name.text = category.name

        if let photoURLString = category.photoThumb.url,
            photoURL = NSURL(string: photoURLString) {
            cell.photo.sd_setImageWithURL(photoURL)
        }

        cell.switched.on = self.selectedCategoriesData.contains(category)

        cell.switched.tag = indexPath.row;
        cell.switched.addTarget(self, action: "switched:", forControlEvents: .TouchUpInside)
        
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var category:Category
        
        switch (selectedCategoryType) {
        case .Private: category = privateCategoriesData[indexPath.row]
        case .Public: category = publicCategoriesData[indexPath.row]
        default: if(indexPath.section == 0) {
            category = publicCategoriesData[indexPath.row]
        } else {
            category = privateCategoriesData[indexPath.row]
            }
        }
        performSegueWithIdentifier("details", sender: category)
    }
    
    @IBAction func allAction(sender: AnyObject) {
        allUnderline.hidden = false
        privateUnderline.hidden = true
        publicUnderline.hidden = true
        selectedCategoryType = CategoryType.All
        allButton.setTitleColor(Color.PrimaryActiveColor, forState: UIControlState.Normal)
        publicButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        privateButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        categories.reloadData()
    }
    
    @IBAction func publicAction(sender: AnyObject) {
        allUnderline.hidden = true
        privateUnderline.hidden = true
        publicUnderline.hidden = false
        selectedCategoryType = CategoryType.Public
        allButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        publicButton.setTitleColor(Color.PrimaryActiveColor, forState: UIControlState.Normal)
        privateButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        categories.reloadData()
    }
    
    @IBAction func privateAction(sender: AnyObject) {
        allUnderline.hidden = true
        privateUnderline.hidden = false
        publicUnderline.hidden = true
        selectedCategoryType = CategoryType.Private
        allButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        publicButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        privateButton.setTitleColor(Color.PrimaryActiveColor, forState: UIControlState.Normal)
        categories.reloadData()
    }
    
    @IBAction func switched(sender: AnyObject) {
        let category = categoriesData[sender.tag]
    
        if (selectedCategoriesData.contains(category)) {
            selectedCategoriesData = selectedCategoriesData.filter({$0.objectId != category.objectId})
        } else {
            selectedCategoriesData.append(category)
        }

        guard let currentUser = ParseHelper.sharedInstance.currentUser else {
            return
        }

        category.attendees.append(currentUser)
        ParseHelper.saveObject(category, completion: nil)
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
                self.privateCategoriesData = self.categoriesData.filter({$0.isPrivate})
                self.publicCategoriesData = self.categoriesData.filter({!$0.isPrivate})
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
            let vc = (segue.destinationViewController as! GroupDetailsViewController)
            vc.group = sender as! Category
            vc.selectedCategoriesData = selectedCategoriesData
        } else if let vc = segue.destinationViewController as? CreateGroupViewController
            where segue.identifier == "create" {
            vc.delegate = self
        }
    }
}

