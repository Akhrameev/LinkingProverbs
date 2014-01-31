//
//  DAO.m
//  LinkedProverbs
//
//  Created by Pavel Akhrameev on 31.01.14.
//  Copyright (c) 2014 Pavel Akhrameev. All rights reserved.
//

#import "DAO.h"
#import "Proverb.h"

@implementation DAO

- (instancetype) init {
    if (self = [super init]) {
        [MagicalRecord setupCoreDataStackWithStoreNamed:@"Proverbs.sqlite"];
    }
    return self;
}

+ (instancetype) sharedInstance
{
    static DAO *__sharedInstance= nil;
    static dispatch_once_t once_token = 0;
    dispatch_once(&once_token, ^
                  {
                      __sharedInstance =  [DAO  new];
                  });
    return __sharedInstance ;
}

#pragma mark - Proverbs getters

- (NSArray *) proverbs {
    return [Proverb MR_findAll];
}

@end
