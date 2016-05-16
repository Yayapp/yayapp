//
//  ImageViewController.swift
//  Friendzi
//
//  Created by Yuriy B. on 4/26/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import UIKit

final class ImageViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet private weak var contentScrollView: UIScrollView?
    @IBOutlet private weak var backgroundImageView: UIImageView?

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

    // MARK: - UIScrollViewDelegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return backgroundImageView
    }
}
