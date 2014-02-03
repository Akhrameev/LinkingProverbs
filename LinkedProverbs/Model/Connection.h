//
//  Connection.h
//  LinkedProverbs
//
//  Created by Pavel Akhrameev on 31.01.14.
//  Copyright (c) 2014 Pavel Akhrameev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Proverb.h"


@interface Connection : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSManagedObject *type;
@property (nonatomic, retain) NSSet *proverbs;

@end

@interface Connection (CoreDataGeneratedAccessors)

- (void)addProverbsObject:(Proverb *)value;
- (void)removeProverbsObject:(Proverb *)value;
- (void)addProverbs:(NSSet *)values;
- (void)removeProverbs:(NSSet *)values;

@end
