//
//  ChooseCategoryCollectionViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 28.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class ChooseCategoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var delegate:ChooseCategoryDelegate!
    var categoriesData:[Category]! = []
    var selectedCategoriesData:[Category]! = []
    var multi:Bool = false
    
    @IBOutlet weak var categories: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories.delegate = self
        categories.dataSource = self
        categories.allowsMultipleSelection = true

        ParseHelper.getCategories({
            (categoriesList:[Category]?, error:NSError?) in
            if(error == nil) {
                self.categoriesData = categoriesList!
                self.categories.reloadData()
            }
        })
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoriesData.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CategoryCollectionViewCell
    
        let category = categoriesData[indexPath.row]
        cell.name.text = category.name
        if (contains(selectedCategoriesData, category)) {
            cell.photo.file = category.photoSelected
        } else {
            cell.photo.file = category.photo
        }
        cell.photo.loadInBackground()
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let category = categoriesData[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CategoryCollectionViewCell
        if (contains(selectedCategoriesData, category)){
            
            category.photo.getDataInBackgroundWithBlock({
                (data:NSData?, error:NSError?) in
                if(error == nil) {
                    var image = UIImage(data:data!)
                    cell.photo.image = image!
                    collectionView.reloadItemsAtIndexPaths([indexPath])
                }
            })
            
            selectedCategoriesData = selectedCategoriesData.filter({$0.objectId != category.objectId})
        } else {
            category.photoSelected.getDataInBackgroundWithBlock({
                (data:NSData?, error:NSError?) in
                if(error == nil) {
                    var image = UIImage(data:data!)
                    cell.photo.image = image!
                    collectionView.reloadItemsAtIndexPaths([indexPath])
                }
            })
            if(multi){
                selectedCategoriesData.append(category)
            } else {
                selectedCategoriesData = [category]
            }
        }
        delegate.madeCategoryChoice(selectedCategoriesData)
        if(!multi){
            self.dismissViewControllerAnimated(true, completion:nil)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: categories.bounds.size.width/2-0.5, height: categories.bounds.size.height/4);
        
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }

    
}
protocol ChooseCategoryDelegate : NSObjectProtocol {
    func madeCategoryChoice(categories: [Category])
}
