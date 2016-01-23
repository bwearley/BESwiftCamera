//
//  VideoViewController.swift
//  BESwiftCamera
//
//  Created by Brian Earley on 1/18/16.
//  Copyright © 2016 brianearley. All rights reserved.
//

import UIKit
import AVFoundation

class VideoViewController: UIViewController {

    var videoUrl:NSURL!
    var avPlayer:AVPlayer!
    var avPlayerLayer:AVPlayerLayer!

    var cancelButton:UIButton {
        let cancelImage = UIImage(named: "cancel.png")
        let button = UIButton(type: .System)
        button.tintColor = UIColor.whiteColor()
        button.frame = CGRectMake(0,0,44,44)
        button.setImage(cancelImage, forState: .Normal)
        button.imageView?.clipsToBounds = false
        button.contentEdgeInsets = UIEdgeInsetsMake(10,10,10,10)
        button.layer.shadowColor = UIColor.blackColor().CGColor
        button.layer.shadowOffset = CGSizeMake(0,0)
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = 1
        button.clipsToBounds = false
        button.addTarget(self, action: Selector("cancelButtonPressed:"), forControlEvents: .TouchUpInside)
        return button
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.whiteColor()

        self.avPlayer = AVPlayer(URL: self.videoUrl)
        self.avPlayer.actionAtItemEnd = .None
        self.avPlayerLayer = AVPlayerLayer(player: self.avPlayer)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerItemDidReachEnd:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.avPlayer.currentItem)

        let screenRect = UIScreen.mainScreen().bounds

        self.avPlayerLayer.frame = CGRectMake(0,0,screenRect.size.width, screenRect.size.height)
        self.view.layer.addSublayer(self.avPlayerLayer)

        // cancel button
        self.view.addSubview(self.cancelButton)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.cancelButton.frame.origin.x = 10
        self.cancelButton.frame.origin.y = 10
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.avPlayer.play()
    }

    init(withVideoURL url:NSURL) {
        super.init(nibName: nil, bundle: nil)
        self.videoUrl = url
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    func playerItemDidReachEnd(notification:NSNotification) {
        let p = notification.object
        p!.seekToTime(kCMTimeZero)
    }

    func cancelButtonPressed(sender:UIButton) {
        print("Cancel button pressed!")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
