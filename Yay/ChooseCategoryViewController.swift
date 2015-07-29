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
    
    @IBOutlet weak var categories: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories.delegate = self
        categories.dataSource = self

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
        cell.photo.file = category.photo
        cell.photo.loadInBackground()
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate.madeCategoryChoice(categoriesData[indexPath.row])
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: categories.bounds.size.width/2-1, height: categories.bounds.size.width/2-1);
        
    }
}
protocol ChooseCategoryDelegate : NSObjectProtocol {
    func madeCategoryChoice(category: Category)
}
