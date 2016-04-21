//
//  CategoryPickerViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 19.02.16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import Foundation
protocol CategoryPickerDelegate : NSObjectProtocol {
    func madeCategoryChoice(categories: [Category])
}

class CategoryPickerViewController: UIViewController, TTGTextTagCollectionViewDelegate {
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var categoryDelegate:CategoryPickerDelegate!
    var categoriesData:[Category]! = []
    var selectedCategoriesData:[Category]! = []
    
    @IBOutlet weak var categoriesCollection: TTGTextTagCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        categoriesCollection.delegate = self
        categoriesCollection.tagTextColor = .blackColor()
        categoriesCollection.tagSelectedTextColor = .whiteColor()
        categoriesCollection.tagSelectedBackgroundColor = Color.PrimaryActiveColor
        categoriesCollection.tagTextFont = UIFont.boldSystemFontOfSize(15)
        categoriesCollection.tagCornerRadius = 10
        categoriesCollection.tagSelectedCornerRadius = 10
        categoriesCollection.tagBorderColor = .blackColor()
        categoriesCollection.tagSelectedBorderWidth = 0
        categoriesCollection.horizontalSpacing = 12
        categoriesCollection.verticalSpacing = 12

        guard let currentUser = ParseHelper.sharedInstance.currentUser else {
            return
        }
        
        ParseHelper.getUserCategoriesForEvent(currentUser, block: {
            (categoriesList:[Category]?, error:NSError?) in
            if(error == nil) {
                self.categoriesData = categoriesList!

                for (index, category) in (categoriesList!.enumerate()) {
                    self.categoriesCollection.addTag(category.name)
                    if self.selectedCategoriesData.contains(category) {
                        self.categoriesCollection.setTagAtIndex(UInt(index), selected: true)
                    }
                }
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
    }
    
    
    func textTagCollectionView(textTagCollectionView: TTGTextTagCollectionView!, didTapTag tagText: String!, atIndex index: UInt, selected: Bool) {
        let category = categoriesData[Int(index)]
        if (selected){
            selectedCategoriesData.append(category)
        } else {
            selectedCategoriesData = selectedCategoriesData.filter({$0.objectId != category.objectId})
        }
    }
    
    
    
    @IBAction func doneAction(sender: AnyObject) {
        categoryDelegate.madeCategoryChoice(selectedCategoriesData)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
