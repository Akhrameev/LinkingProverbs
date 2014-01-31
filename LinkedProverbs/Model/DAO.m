//
//  DAO.m
//  LinkedProverbs
//
//  Created by Pavel Akhrameev on 31.01.14.
//  Copyright (c) 2014 Pavel Akhrameev. All rights reserved.
//

#import "DAO.h"
#import "Proverb.h"

@implementation DAO {
    NSArray *cachedProverbs;
    NSDictionary *cachedProverbsRequestProperties;
}

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

- (void)dealloc {
    cachedProverbs = nil;
}

#pragma mark - Proverbs getters

- (void) proverbsWithReload:(BOOL)reload {
    if (cachedProverbs) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DAOProverbsUpdated object:cachedProverbs];
        if (!reload) {  //здесь нужна проверка, то ли обновляем
            return;
        }
    }
    NSArray *results = [Proverb MR_findAll];
    if (results.count)
        cachedProverbs = results;
    [[NSNotificationCenter defaultCenter] postNotificationName:DAOProverbsUpdated object:results];
}

@end
