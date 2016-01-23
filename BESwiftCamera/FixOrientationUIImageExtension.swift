//
// FixOrientationUIImageExtension.swift
// Biception
// Translated from LLSimpleCamera
// https://github.com/omergul123/LLSimpleCamera
// 
// http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
//

import UIKit

extension UIImage {
	func fixOrientation() -> UIImage {
        let π = CGFloat(M_PI)
        let π_2 = CGFloat(M_PI_2)

		// No-op if the orientation is already correct
		if self.imageOrientation == .Up { return self }
		
		// We need to calculate the proper transformation to make the image upright.
		// We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
		var transform = CGAffineTransformIdentity
		
		switch self.imageOrientation {
			case .Down: break
			case .DownMirrored:
				transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height)
				transform = CGAffineTransformRotate(transform, π)
			case .Left: break
			case .LeftMirrored:
				transform = CGAffineTransformTranslate(transform, self.size.width, 0)
				transform = CGAffineTransformRotate(transform, π_2)
			case .Right: break
			case .RightMirrored:
				transform = CGAffineTransformTranslate(transform, 0, self.size.height)
				transform = CGAffineTransformRotate(transform, -π_2)
			case .Up: break
			case .UpMirrored: break
			//default:
		}
		
		switch self.imageOrientation {
			case .UpMirrored: break
			case .DownMirrored:
				transform = CGAffineTransformTranslate(transform, self.size.width, 0)
				transform = CGAffineTransformScale(transform, -1, 1)
			case .LeftMirrored: break
			case .RightMirrored:
				transform = CGAffineTransformTranslate(transform, self.size.height, 0)
				transform = CGAffineTransformScale(transform, -1, 1)
			case .Up: break
			case .Down: break
			case .Left: break
			case .Right: break
			//default:
		}
		
		// Now we draw the underlying CGImage into a new context, applying the transform calculated above.
		let ctx = CGBitmapContextCreate(
            nil,
            Int(self.size.width),
            Int(self.size.height),
            CGImageGetBitsPerComponent(self.CGImage),
            0,
            CGImageGetColorSpace(self.CGImage),
            CGImageGetBitmapInfo(self.CGImage).rawValue)

		CGContextConcatCTM(ctx, transform)
		switch self.imageOrientation {
			case .Left: break
			case .LeftMirrored: break
			case .Right: break
			case .RightMirrored:
				// Grr...
				CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage)
			default:
				CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage)
		}
		
		// And now we just create a new UIImage from the drawing context
		let cgimg = CGBitmapContextCreateImage(ctx)
        return UIImage(CGImage:cgimg!)
	}
}