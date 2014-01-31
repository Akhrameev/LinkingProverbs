//
//  UIImage+rotate.h
//  LinkedProverbs
//
//  Created by Pavel Akhrameev on 31.01.14.
//  Copyright (c) 2014 Pavel Akhrameev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (rotate)
- (UIImage *) rotateToDeviceOrientation: (UIDeviceOrientation) deviceOrientation;
@end
