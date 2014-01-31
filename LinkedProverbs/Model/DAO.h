//
//  DAO.h
//  LinkedProverbs
//
//  Created by Pavel Akhrameev on 31.01.14.
//  Copyright (c) 2014 Pavel Akhrameev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DAO : NSObject

+ (instancetype) sharedInstance;

- (NSArray *) proverbs;

@end
