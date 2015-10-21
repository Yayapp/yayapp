//
//  StartViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class StartViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    @IBOutlet weak var dots: UIPageControl!
    
    var timer:NSTimer!
    var pageViewController : UIPageViewController!
    var currentIndex : Int = 0
    var pageImages : Array<String> = ["background_start1", "background_start2", "background_start3"]
    var pageTitles : Array<String> = [
        "<style type='text/css'>* {font-family:HelveticaNeue-Light;font-size: 24pt; color:#ffffff; text-align: center;}</style><center><b>Making good times happen.</b></center>",
        "<style type='text/css'>* {font-family:HelveticaNeue-Light;font-size: 24pt; color:#ffffff; text-align: center;}</style><center><b>For all the fun people you haven't yet met</b></center>",
        "<style type='text/css'>* {font-family:HelveticaNeue-Light;font-size: 24pt; color:#ffffff; text-align: center;}</style><center><b>For <span style=\"color:#fa0001;\">all the</span> <span style=\"color:#216288;\">FUN</span> <span style=\"color:#66e3fe;\">sTuPid</span> </b><span style=\"color:#ff7af0;\">crazy</span>, <b><span style=\"color:#f4ff1c;\">amazing</span> <u><span style=\"color:#11e037;\">beautiful</span></u>, <i><span style=\"color:#fa0001;\">daring</span></i> things you want to do.</b></center>"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let pageSpacing:NSNumber = DeviceType.IS_IPHONE_4_OR_LESS ? 0 : DeviceType.IS_IPHONE_5 ? 30 : DeviceType.IS_IPHONE_6 ? 35 : 40
        let dictionary:[String : AnyObject] = [UIPageViewControllerOptionInterPageSpacingKey:pageSpacing]
        
        pageViewController = UIPageViewController(transitionStyle:UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options:dictionary)
        
        self.pageViewController!.dataSource = self
        self.pageViewController!.delegate = self
   
        let pageContentViewController:InstructionViewController! = self.viewControllerAtIndex(0)
        
        self.pageViewController.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        pageViewController!.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
        
        addChildViewController(pageViewController!)
        view.insertSubview(pageViewController!.view, atIndex: 0)
        pageViewController!.didMoveToParentViewController(self)
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "swipe", userInfo: nil, repeats: true)

    }
 
    
    @IBAction func login(sender: AnyObject) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        vc.isLogin = true
        presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func signup(sender: AnyObject) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func swipe(){
        var i:Int! = 0
        if(currentIndex<2) {
            i = currentIndex + 1
        }
        self.pageViewController.setViewControllers([self.viewControllerAtIndex(i)!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        self.dots.currentPage = currentIndex
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! InstructionViewController).pageIndex
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index--
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! InstructionViewController).pageIndex
        
        if index == NSNotFound {
            return nil
        }
        
        index++
       
        if (index == self.pageTitles.count) {
            return nil
        }
        
        return viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index: Int) -> InstructionViewController!
    {
        // Create a new view controller and pass suitable data.
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("InstructionViewController") as! InstructionViewController
        pageContentViewController.imageName = pageImages[index]
        let attrString = try? NSMutableAttributedString(
            data: pageTitles[index].dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        pageContentViewController.titleText = attrString
        pageContentViewController.pageIndex = index
        currentIndex = index
        return pageContentViewController
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if(completed){
            let enlarge:InstructionViewController = (self.pageViewController.viewControllers as! [InstructionViewController]).last!
            self.dots.currentPage =  enlarge.pageIndex;
            currentIndex = enlarge.pageIndex;
            timer.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "swipe", userInfo: nil, repeats: true)
        }
    }
}
