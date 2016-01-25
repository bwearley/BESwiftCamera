//
//  ViewController.swift
//  BESwiftCamera
//
//  Created by Brian Earley on 1/18/16.
//  Copyright © 2016 brianearley. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var camera:BESwiftCamera!
    var errorLabel:UILabel!
    var snapButton:UIButton!
    var switchButton:UIButton!
    var flashButton:UIButton!
    var segmentedControl:UISegmentedControl!

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.attachCamera()
    }

    func attachCamera() {
        do {
            try self.camera.start()
        } catch BESwiftCameraErrorCode.CameraPermission {
            self.showCameraPermissionAlert()
        } catch BESwiftCameraErrorCode.MicrophonePermission {
            self.showMicrophonePermissionAlert()
        } catch {
            self.showUnknownErrorAlert()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.blackColor()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        let screenRect = UIScreen.mainScreen().bounds

        // Configure Camera
        self.camera = BESwiftCamera(withQuality: AVCaptureSessionPresetHigh, position: .Rear, videoEnabled: true)
        self.camera.attachToViewController(self, withFrame: CGRectMake(0,0,screenRect.size.width,screenRect.size.height))
        self.camera.fixOrientationAfterCapture = true
        self.camera.onDeviceChange = {
            [weak self] camera, device in
            if camera.isFlashAvailable() {
                self!.flashButton.hidden = false

                if camera.flash == BESwiftCameraFlash.Off {
                    self!.flashButton.selected = false
                } else {
                    self!.flashButton.selected = true
                }
            } else {
                self!.flashButton.hidden = true
            }
        }

        // Snap/Record Button
        self.snapButton = UIButton(type: .Custom)
        self.snapButton.frame = CGRectMake(0, 0, 70.0, 70.0)
        self.snapButton.clipsToBounds = true
        self.snapButton.layer.cornerRadius = self.snapButton.frame.size.width / 2.0
        self.snapButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.snapButton.layer.borderWidth = 2.0
        self.snapButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        self.snapButton.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.snapButton.layer.shouldRasterize = true
        self.snapButton.addTarget(self, action: Selector("snapButtonPressed:"), forControlEvents: .TouchUpInside)
        self.view.addSubview(self.snapButton)

        // Flash Toggle Button
        self.flashButton = UIButton(type: .System)
        self.flashButton.frame = CGRectMake(0, 0, 16.0 + 20.0, 24.0 + 20.0)
        self.flashButton.tintColor = UIColor.whiteColor()
        self.flashButton.setImage(UIImage(named: "camera-flash.png"), forState: .Normal)
        self.flashButton.imageEdgeInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
        self.flashButton.addTarget(self, action: Selector("flashButtonPressed:"), forControlEvents: .TouchUpInside)
        self.view.addSubview(self.flashButton)

        // Front/Rear Camera Toggle
        if BESwiftCamera.isFrontCameraAvailable() && BESwiftCamera.isRearCameraAvailable() {
            // button to toggle camera positions
            self.switchButton = UIButton(type: .System)
            self.switchButton.frame = CGRectMake(0, 0, 29.0 + 20.0, 22.0 + 20.0)
            self.switchButton.tintColor = UIColor.whiteColor()
            self.switchButton.setImage(UIImage(named: "camera-switch.png"), forState: .Normal)
            self.switchButton.imageEdgeInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
            self.switchButton.addTarget(self, action: Selector("switchButtonPressed:"), forControlEvents: .TouchUpInside)
            self.view.addSubview(self.switchButton)
        }

        // Photo/Video Toggle
        self.segmentedControl = UISegmentedControl(items: ["Picture","Video"])
        self.segmentedControl.frame = CGRectMake(12.0, screenRect.size.height - 67.0, 120.0, 32.0)
        self.segmentedControl.selectedSegmentIndex = 0
        self.segmentedControl.tintColor = UIColor.whiteColor()
        self.segmentedControl.addTarget(self, action: Selector("segmentedControlValueChanged:"), forControlEvents: .ValueChanged)
        self.view.addSubview(self.segmentedControl)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .Portrait
    }

    func switchButtonPressed(sender:UIButton) {
        self.camera.togglePosition()
    }

    var applicationDocumentsDirectory:NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
    }

    func flashButtonPressed(sender:UIButton) {
        if self.camera.flash == .Off {
            if self.camera.updateFlashMode(.On) {
                self.flashButton.selected = true
                self.flashButton.tintColor = UIColor.yellowColor()
            }
        } else {
            if self.camera.updateFlashMode(.Off) {
                self.flashButton.selected = false
                self.flashButton.tintColor = UIColor.whiteColor()
            }
        }
    }

    func segmentedControlValueChanged(sender:UISegmentedControlSegment) {
        print("Segment value changed.")
    }

    func snapButtonPressed(sender:UIButton) {
        if self.segmentedControl.selectedSegmentIndex == 0 {
            // Capture
            self.camera.capture(exactSeenImage:true) {
                [weak self] camera,image,dictionary in
                camera.performSelector(Selector("stop"), withObject: nil, afterDelay: 0.2)
                let imageVC = ImageViewController(withImage: image)
                self!.presentViewController(imageVC, animated: true, completion: nil)
            }
        } else {
            if self.camera.isRecording() == false {
                // Not Recording -> Start Recording
                self.hideControlElements()

                self.styleSnapButtonAsRecording()

                // start recording
                let outputURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("thisVideo").URLByAppendingPathExtension("mov")
                do {
                    try self.camera.startRecordingWithOutputUrl(outputURL)
                } catch {
                    self.styleSnapButtonAsNotRecording()
                    self.showControlElements()
                }
                //try! self.camera.startRecordingWithOutputUrl(outputURL)
            } else {
                // Recording -> Stop Recording
                self.showControlElements()

                self.styleSnapButtonAsNotRecording()

                self.camera.stopRecording() {
                    [weak self] camera,outputFileURL in
                    let vc = VideoViewController(withVideoURL:outputFileURL)
                    self!.presentViewController(vc, animated: true, completion: nil)
                }
            }
        }
    }

    func hideControlElements() {
        self.segmentedControl.hidden = true
        self.flashButton.hidden = true
        self.switchButton.hidden = true
    }

    func showControlElements() {
        self.segmentedControl.hidden = false
        self.flashButton.hidden = false
        self.switchButton.hidden = false
    }

    func styleSnapButtonAsRecording() {
        self.snapButton.layer.borderColor = UIColor.redColor().CGColor
        self.snapButton.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.5)
    }

    func styleSnapButtonAsNotRecording() {
        self.snapButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.snapButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        self.camera.view.frame = self.view.bounds

        self.snapButton.center = self.view.center

        self.flashButton.center = self.view.center

        self.snapButton.center = self.view.center
        self.snapButton.frame.origin.y = (self.view.frame.height - 15)-self.snapButton.frame.height

        self.flashButton.center = self.view.center
        self.flashButton.frame.origin.y = 5

        if let _ = self.switchButton {
            self.switchButton.frame.origin.y = 5
            self.switchButton.frame.origin.x = (self.view.frame.size.width - 5.0) - self.switchButton.frame.size.width
        }

        self.segmentedControl.frame.origin.x = 12
        self.segmentedControl.frame.origin.y = (self.view.frame.size.height - 35.0)-self.segmentedControl.frame.height
        
    }

    // MARK: UIAlertControllers

    func showCameraPermissionAlert() {
        let alertController = UIAlertController(
            title: "Camera Permission Denied",
            message: "You have not allowed access to the camera.",
            preferredStyle: .Alert)

        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)

        alertController.addAction(defaultAction)
        self.camera.presentViewController(alertController, animated: true, completion: nil)
    }

    func showMicrophonePermissionAlert() {
        let alertController = UIAlertController(
            title: "Microphone Permission Denied",
            message: "You have not allowed access to the microphone.",
            preferredStyle: .Alert)

        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)

        alertController.addAction(defaultAction)
        self.camera.presentViewController(alertController, animated: true, completion: nil)
    }

    func showUnknownErrorAlert() {
        let alertController = UIAlertController(
            title: "Unknown Error",
            message: "An unknown error has occurred with the camera.",
            preferredStyle: .Alert)

        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)

        alertController.addAction(defaultAction)
        self.camera.presentViewController(alertController, animated: true, completion: nil)
    }

}

