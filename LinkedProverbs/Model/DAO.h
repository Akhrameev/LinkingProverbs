//
//  DAO.h
//  LinkedProverbs
//
//  Created by Pavel Akhrameev on 31.01.14.
//  Copyright (c) 2014 Pavel Akhrameev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConnectionType.h"
#import "Connection.h"

typedef NS_ENUM(NSUInteger, standartConnectionType) {
    sctLanguage = 1,
    sctCount
};

@interface DAO : NSObject

+ (instancetype) sharedInstance;

- (void) proverbsWithReload:(BOOL)reload;

- (NSDictionary *) standartConnectionTypes;
- (NSSet *)connectionTypeWithName:(NSString *)name;
- (NSSet *) connectionsOfType:(ConnectionType *)type;
- (NSSet *) connectionsOfStandartType:(standartConnectionType)stdType;
- (NSSet *) connectionsWithName:(NSString *)name;

@end
