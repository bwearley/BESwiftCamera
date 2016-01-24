# BESwiftCamera: simple camera controller for iOS written in Swift 
BESwiftCamera is a simple camera controller for taking photos/videos in iOS applications written in Swift 2.0. Ported from LLSimpleCamera in Objective-C.

## Installation
Installation only requires importing BESwiftCamera.swift into your project. The following code snippets provide examples for how to initialize the camera and capture photos and videos.

## Initializing Camera
```swift
class ViewController: UIViewController {
    var camera:BESwiftCamera!
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
        let screenRect = UIScreen.mainScreen().bounds

        // Configure Camera
        self.camera = BESwiftCamera(withQuality: AVCaptureSessionPresetHigh, position: .Rear, videoEnabled: true)
        self.camera.attachToViewController(self, withFrame: CGRectMake(0,0,screenRect.size.width,screenRect.size.height))
    ...
    }
}
```

## Capturing Photo
```swift
self.camera.capture(exactSeenImage:true) {
    [weak self] camera,image,dictionary in
    camera.performSelector(Selector("stop"), withObject: nil, afterDelay: 0.2)
    let imageVC = ImageViewController(withImage: image)
    self!.presentViewController(imageVC, animated: true, completion: nil)
}
```

## Recording Video
```swift
let outputURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("thisVideo").URLByAppendingPathExtension("mov")
do {
   try self.camera.startRecordingWithOutputUrl(outputURL)
} catch {}
```
