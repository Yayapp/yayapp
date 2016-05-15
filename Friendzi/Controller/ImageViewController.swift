//
//  ImageViewController.swift
//  Friendzi
//
//  Created by Yuriy B. on 4/26/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var contentScrollView: UIScrollView?
    @IBOutlet weak var backgroundImageView: UIImageView?

    var backgroundImage: UIImage?
    var imageTapped: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImageView?.image = backgroundImage
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageViewController.imageWasTapped))
        backgroundImageView?.userInteractionEnabled = true
        backgroundImageView?.addGestureRecognizer(tapGestureRecognizer)
        
        contentScrollView?.delegate = self
        contentScrollView?.minimumZoomScale = 1
        contentScrollView?.maximumZoomScale = 3
    }

    func imageWasTapped() {
        imageTapped?()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return backgroundImageView
    }
}
