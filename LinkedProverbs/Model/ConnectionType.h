//
//  ConnectionType.h
//  LinkedProverbs
//
//  Created by Pavel Akhrameev on 31.01.14.
//  Copyright (c) 2014 Pavel Akhrameev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Connection;

@interface ConnectionType : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSSet *connections;
@end

@interface ConnectionType (CoreDataGeneratedAccessors)

- (void)addConnectionsObject:(Connection *)value;
- (void)removeConnectionsObject:(Connection *)value;
- (void)addConnections:(NSSet *)values;
- (void)removeConnections:(NSSet *)values;

@end
