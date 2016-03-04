//
//  ChooseCategoryCollectionViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 28.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class ChooseCategoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, GroupChangeDelegate, UIPopoverPresentationControllerDelegate {

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
    var categoriesData:[Category]! = []
    var privateCategoriesData:[Category]! = []
    var publicCategoriesData:[Category]! = []
    var selectedCategoriesData:[Category]! = []
    var selectedCategoryType: CategoryType = CategoryType.All
    var isEventCreation:Bool = false
    var bottomConstraint:NSLayoutConstraint!
    var topConstraint:NSLayoutConstraint!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomConstraint = NSLayoutConstraint (item: categories,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: -20)
        
        categories.delegate = self
        categories.dataSource = self
        
        ParseHelper.getUserCategories(PFUser.currentUser()!, block: {
            (categoriesList:[Category]?, error:NSError?) in
            if(error == nil) {
                self.selectedCategoriesData = categoriesList!
                self.allAction(true)
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
        
        
        ParseHelper.getCategories({
            (categoriesList:[Category]?, error:NSError?) in
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
        
        switch kind {
            //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView =
            collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                withReuseIdentifier: "CategoryHeader",
                forIndexPath: indexPath)
                as! CategoryHeader
            if selectedCategoryType == CategoryType.All{
                if(indexPath.section == 0) {
                    headerView.name.text = "Public Groups"
                } else {
                    headerView.name.text = "Private Groups"
                }
            } else {
                headerView.name.text = ""
            }
            return headerView
        default:
            //4
            assert(false, "Unexpected element kind")
        }
        return CategoryHeader()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CategoryCollectionViewCell
    
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
        cell.name.text = category.name
        category.photo.getDataInBackgroundWithBlock({
                (data:NSData?, error:NSError?) in
                if(error == nil) {
                    let image = UIImage(data:data!)
                    
                    cell.photo.image = image!
                    cell.photo.layer.cornerRadius = CGRectGetWidth(cell.photo.frame)/2.0
                    cell.photo.layer.masksToBounds = true
                } else {
                    MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                }
            })
//        }
        if (self.selectedCategoriesData.contains(category)) {
            cell.switched.on = true
        } else {
            cell.switched.on = false
        }
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
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        return CGSize(width: (categories.bounds.size.width/3 - 10), height: (categories.bounds.size.width/2));
//    }
    
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
    
    func invite(group:Category){
        let map = self.storyboard!.instantiateViewControllerWithIdentifier("InviteViewController") as! InviteViewController
        
        map.modalPresentationStyle = UIModalPresentationStyle.Popover
        map.preferredContentSize = CGSizeMake(self.view.frame.width, 300)
        map.group = group
        
        let detailPopover: UIPopoverPresentationController = map.popoverPresentationController!
        detailPopover.delegate = self
        detailPopover.sourceView = categories
        
        presentViewController(map,
            animated: true, completion:nil)
    }
    
    @IBAction func switched(sender: AnyObject) {
        let category = categoriesData[sender.tag]
    
        if (selectedCategoriesData.contains(category)){
            selectedCategoriesData = selectedCategoriesData.filter({$0.objectId != category.objectId})
        } else {
            selectedCategoriesData.append(category)
        }
        if (!isEventCreation){
            category.attendees.append(PFUser.currentUser()!)
            category.saveInBackground()
        }
    }
    
    @IBAction func searchAction(sender: AnyObject) {
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        presentViewController(searchController, animated: true, completion: nil)
        
    }

    
    func searchBar(searchBar: UISearchBar,
        textDidChange searchText: String) {
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
            (categoriesList:[Category]?, error:NSError?) in
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
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.None
    }
    
    func groupCreated(group:Category) {
        categoriesData.append(group)
        allAction(true)
        invite(group)
    }
    func groupChanged(group:Category) {
    }
    func groupRemoved(group:Category) {
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "details") {
            let vc = (segue.destinationViewController as! GroupDetailsViewController)
            vc.group = sender as! Category
            vc.delegate = self
            vc.selectedCategoriesData = selectedCategoriesData
        } else if(segue.identifier == "create") {
            let vc = (segue.destinationViewController as! CreateGroupViewController)
            vc.delegate = self
        }
    }
}

