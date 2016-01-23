//
//  ImageViewController.swift
//  BESwiftCamera
//
//  Created by Brian Earley on 1/18/16.
//  Copyright © 2016 brianearley. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    var image:UIImage!
    var imageView:UIImageView!
    var infoLabel:UILabel!
    var cancelButton:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        let screenRect:CGRect = UIScreen.mainScreen().bounds

        self.imageView = UIImageView(image: self.image)
        self.imageView.frame = screenRect
        self.imageView.backgroundColor = UIColor.blackColor()
        self.imageView.contentMode = .ScaleAspectFill
        self.imageView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.imageView)

        let info = "Size: \(self.image.size) - Orientation: \(self.image.imageOrientation)"

        self.infoLabel = UILabel(frame: CGRectMake(0,0,100,20))
        self.infoLabel.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.7)
        self.infoLabel.textColor = UIColor.whiteColor()
        self.infoLabel.font = UIFont(name: "AvenirNext-Regular", size: 13)
        self.infoLabel.textAlignment = .Center
        self.infoLabel.text = info
        self.view.addSubview(self.infoLabel)

        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("viewTapped:"))
        self.view.addGestureRecognizer(tapGesture)
    }

    func viewTapped(sender:UIButton) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }

    init(withImage image:UIImage?) {
        super.init(nibName: nil, bundle: nil)

        if let _ = image {
            self.image = image
        } else {
            self.image = UIImage()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        self.imageView.frame = self.view.bounds

        self.infoLabel.sizeToFit()
        self.infoLabel.frame.size.width = self.view.bounds.size.width
    }

}
