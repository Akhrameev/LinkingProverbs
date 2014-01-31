//
//  UPProverbCollectionCell.m
//  LinkedProverbs
//
//  Created by Pavel Akhrameev on 31.01.14.
//  Copyright (c) 2014 Pavel Akhrameev. All rights reserved.
//

#import "UPProverbCollectionCell.h"
#import "UIImage+Tint.h"
#import "UIColor+MLPFlatColors.h"
#import "UIImageCache.h"

@implementation UPProverbCollectionCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.nameLabel.numberOfLines = 0;
    static NSString *starImageInCellName = @"starImageInCellName";
    UIImage *img = [[UIImageCache sharedInstance] imageCachedWithName:starImageInCellName];
    if (!img) {
        img = [self.starImage.image imageTintedWithColor:[UIColor flatDarkYellowColor]];
        [[UIImageCache sharedInstance] cacheImage:img withName:starImageInCellName];
    }
    [self.starImage setImage:img];
}

@end
