//
//  UIImage+Resize.h
//  LinkedProverbs
//
//  Created by Pavel Akhrameev on 31.01.14.
//  Copyright (c) 2014 Pavel Akhrameev. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UIImage (Resize)
- (UIImage *) resizeToSize: (CGSize) size;
+ (UIImage *) imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width;
+ (UIImage *) imageWithImage: (UIImage*) sourceImage scaledToHeight: (float) i_height;
+ (UIImage *) imageWithColor:(UIColor *)color;
+ (UIImage *) imageWithColor:(UIColor *)color andRect:(CGRect)rect;
@end
