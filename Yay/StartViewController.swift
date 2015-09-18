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
        "<style type='text/css'>* {font-size: 14pt; color:#ffffff; text-align: center;}</style><center>Making good times happen.</center>",
        "<style type='text/css'>* {font-size: 14pt; color:#ffffff; text-align: center;}</style><center>For all the fun people you haven't yet met</center>",
        "<style type='text/css'>* {font-size: 14pt; color:#ffffff; text-align: center;}</style><center>For all the <span style=\"color:#FBFD29;\">FUN</span>, <span style=\"font-size: 10pt;\">St</span><span style=\"font-size: 17pt;\">u</span>pid, <span style=\"font-size: 17pt;color:#4DDD47;\">crazy</span>, <b><span style=\"font-size: 17pt;color:#55D9FB;\">amazing</span></b>, <u><span style=\"color:#D600F9;\">beautiful</span></u>, <i><span style=\"color:#E50128;\">daring</span></i> things you want to do.</center>"   
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
enum UIUserInterfaceIdiom : Int
{
    case Unspecified
    case Phone
    case Pad
}

struct ScreenSize
{
    static let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}
struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS =  UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
}