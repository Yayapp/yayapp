//
//  PhotosTableViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 01.09.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

class PhotosTableViewController: UITableViewController {

    var eventPhotos:[EventPhoto] = []
    var category:Category!
    var delegate:ChooseCategoryPhotoDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let back = UIBarButtonItem(image:UIImage(named: "notifications_backarrow"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("backButtonTapped:"))
        back.tintColor = UIColor(red:CGFloat(3/255.0), green:CGFloat(118/255.0), blue:CGFloat(114/255.0), alpha: 1)
        self.navigationItem.setLeftBarButtonItem(back, animated: false)
        
        ParseHelper.getEventPhotos(category, block: {
            result, error in
            self.eventPhotos = result!
            self.tableView.reloadData()
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.height/3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventPhotos.count
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate.madeCategoryPhotoChoice(eventPhotos[indexPath.row])
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let eventPhoto = eventPhotos[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EventPhotoTableViewCell

        eventPhoto.photo.getDataInBackgroundWithBlock({
            (data:NSData?, error:NSError?) in
            if(error == nil) {
                var image = UIImage(data:data!)
                cell.photo.image = self.toCobalt(image!)
            }
        })
        return cell
    }

    
    func toCobalt(image:UIImage) -> UIImage{
        let inputImage:CIImage = CIImage(CGImage: image.CGImage)
        
        // Make the filter
        let colorMatrixFilter:CIFilter = CIFilter(name: "CIColorMatrix")
        colorMatrixFilter.setDefaults()
        colorMatrixFilter.setValue(inputImage, forKey:kCIInputImageKey)
        colorMatrixFilter.setValue(CIVector(x:1, y:0, z:0, w:0), forKey:"inputRVector")
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
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

}
protocol ChooseCategoryPhotoDelegate : NSObjectProtocol {
    func madeCategoryPhotoChoice(eventPhoto: EventPhoto)
}
