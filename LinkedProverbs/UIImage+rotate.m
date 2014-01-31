//
//  UIImage+rotate.m
//  LinkedProverbs
//
//  Created by Pavel Akhrameev on 31.01.14.
//  Copyright (c) 2014 Pavel Akhrameev. All rights reserved.
//

#import "UIImage+rotate.h"

@implementation UIImage (rotate)
- (UIImage *) rotateToDeviceOrientation: (UIDeviceOrientation) deviceOrientation
{
    switch (deviceOrientation)
    {
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationPortraitUpsideDown:
            return [[UIImage alloc] initWithCGImage: self.CGImage
                                              scale: 1.0
                                        orientation: UIImageOrientationDown];
        case UIDeviceOrientationLandscapeLeft:
            return [[UIImage alloc] initWithCGImage: self.CGImage
                                              scale: 1.0
                                        orientation: UIImageOrientationLeft];
        case UIDeviceOrientationLandscapeRight:
            return [[UIImage alloc] initWithCGImage: self.CGImage
                                              scale: 1.0
                                        orientation: UIImageOrientationRight];
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationUnknown:
            return self;
    }

}
@end
