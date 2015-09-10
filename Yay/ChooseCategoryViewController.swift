//
//  ChooseCategoryCollectionViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 28.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class ChooseCategoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var delegate:ChooseCategoryDelegate!
    var categoriesData:[Category]! = []
    var selectedCategoriesData:[Category]! = []
    var multi:Bool = false
    var isEventCreation:Bool = false
    
    @IBOutlet weak var categories: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories.delegate = self
        categories.dataSource = self
        categories.allowsMultipleSelection = true
        
        if(!isEventCreation) {
            appDelegate.centerContainer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.None
        }
        
        ParseHelper.getCategories({
            (categoriesList:[Category]?, error:NSError?) in
            if(error == nil) {
                self.categoriesData = categoriesList!
                self.categories.reloadData()
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoriesData.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CategoryCollectionViewCell
    
        let category = categoriesData[indexPath.row]
        cell.name.text = category.name
        
        category.photoSelected.getDataInBackgroundWithBlock({
            (data:NSData?, error:NSError?) in
            if(error == nil) {
                var image = UIImage(data:data!)
                if (contains(self.selectedCategoriesData, category)) {
                    cell.photo.image = self.toCobalt(image!)
                } else {
                    cell.photo.image = image!
                }
                
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let category = categoriesData[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CategoryCollectionViewCell
        if (contains(selectedCategoriesData, category)){
            selectedCategoriesData = selectedCategoriesData.filter({$0.objectId != category.objectId})
            collectionView.reloadItemsAtIndexPaths([indexPath])
        } else {
            if(multi){
                selectedCategoriesData.append(category)
            } else {
                if(!selectedCategoriesData.isEmpty){
                    collectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: find(categoriesData, selectedCategoriesData.first!)!, inSection: 0)])
                }
                selectedCategoriesData = [category]
            }
            collectionView.reloadItemsAtIndexPaths([indexPath])
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: categories.bounds.size.width/2-0.5, height: categories.bounds.size.height/4);
    }
    
    @IBAction func close(sender: AnyObject) {
        delegate.madeCategoryChoice(selectedCategoriesData)
        self.dismissViewControllerAnimated(true, completion:nil)
    }

    func toCobalt(image:UIImage) -> UIImage{
        let inputImage:CIImage = CIImage(CGImage: image.CGImage)
        
        // Make the filter
        let colorMatrixFilter:CIFilter = CIFilter(name: "CIColorMatrix")
        colorMatrixFilter.setDefaults()
        colorMatrixFilter.setValue(inputImage, forKey:kCIInputImageKey)
        colorMatrixFilter.setValue(CIVector(x:1, y:1, z:1, w:0), forKey:"inputRVector")
        colorMatrixFilter.setValue(CIVector(x:0, y:1, z:0, w:0), forKey:"inputGVector")
        colorMatrixFilter.setValue(CIVector(x:0, y:0, z:1, w:0), forKey:"inputBVector")
        colorMatrixFilter.setValue(CIVector(x:1, y:0, z:0, w:1), forKey:"inputAVector")
        
        // Get the output image recipe
        let outputImage:CIImage = colorMatrixFilter.outputImage
        
        // Create the context and instruct CoreImage to draw the output image recipe into a CGImage
        let context:CIContext = CIContext(options:nil)
        let cgimg:CGImageRef = context.createCGImage(outputImage, fromRect:outputImage.extent()) // 10
        
        return UIImage(CGImage:cgimg)!
    }
    deinit {
        if(!isEventCreation) {
            appDelegate.centerContainer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
        }
    }
    
}
protocol ChooseCategoryDelegate : NSObjectProtocol {
    func madeCategoryChoice(categories: [Category])
}
