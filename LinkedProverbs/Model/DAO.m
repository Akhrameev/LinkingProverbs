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
        NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSURL *documentPath = [paths lastObject];
        NSString *name = @"Proverbs";
        NSString *type = @"sqlite";
        NSString *component = [NSString stringWithFormat:@"%@.%@", name, type];
        NSURL *storeURL = [documentPath URLByAppendingPathComponent:component];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
            NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:type];
            if (path) {
                NSURL *preloadURL = [NSURL fileURLWithPath:path];
                NSError* err = nil;
                
                if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
                    NSLog(@"Error: Unable to copy preloaded database.");
                }
            }
        }
        [MagicalRecord setupCoreDataStackWithStoreNamed:component];
        //temp
        if (![ConnectionType MR_findAll].count) {
            [self createDefaultProverbs];
        }
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

#pragma mark - Connections

- (NSSet *)connectionsOfStandartType:(standartConnectionType)stdType {
    switch (stdType) {
        case sctLanguage:
        {
            NSDictionary *stdConnectionTypes = [self standartConnectionTypes];
            ConnectionType *type = [stdConnectionTypes valueForKey:[@(stdType) stringValue]];
            if (type) {
                NSSet *connections = [self connectionsOfType:type];
                if (!connections.count) {
#warning default creation of objects
                    
                }
                return [self connectionsOfType:type];
            }
            break;
        }
            
        default:
            break;
    }
    return nil;
}

- (NSSet *)connectionsOfType:(ConnectionType *)type {
    return type.connections;
}

- (NSSet *)connectionsWithName:(NSString *)name {
    NSArray *connections = [Connection MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"self.name as %@", name]];
    return [NSSet setWithArray:connections];
}

#pragma mark - ConnectionTypes

- (NSSet *)connectionTypeWithName:(NSString *)name {
    NSArray *connectionTypes = [ConnectionType MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"self.name as %@", name]];
    return [NSSet setWithArray:connectionTypes];
}

#pragma mark StandartConnectionTypes

- (NSArray *) standartConnectionTypesIdsArray {
    static NSArray *__standartConnectionTypesIdsArray = nil;
    if (__standartConnectionTypesIdsArray)
        return __standartConnectionTypesIdsArray;
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:sctCount];
    for (NSUInteger i = 1; i < sctCount; ++i) {
        [tmp addObject:@(i)];
    }
    __standartConnectionTypesIdsArray = [tmp copy];
    return __standartConnectionTypesIdsArray;
}

- (NSDictionary *) standartConnectionTypes {
    static NSDictionary * __stdConnectionTypes = nil;
    if (!__stdConnectionTypes) {
        NSArray *stdConTypes = [ConnectionType MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"self.id in %@", [self standartConnectionTypesIdsArray]]];
        if (!stdConTypes.count) {
#warning default creation of objects
            NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithCapacity:sctCount];
            __weak NSMutableDictionary *mdicInBlock = mdic;
            
        }
        else {
            NSMutableDictionary *stdConTypesM = [NSMutableDictionary dictionaryWithCapacity:stdConTypes.count];
            for (ConnectionType *type in stdConTypes) {
                NSString *key = [type.id stringValue];
                [stdConTypesM setValue:type forKey:key];
            }
            __stdConnectionTypes = stdConTypesM;
        }
    }
    return __stdConnectionTypes;
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
#warning default creation of objects
    if (!cachedProverbs.count)
    {
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DAOProverbsUpdated object:results];
}

#pragma mark - default Creation

- (void) createDefaultProverbs {
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *proverbs = @[@"Муха села на варенье - вот и все стихотворенье", @"Бежал от дыма и упал в огонь.",
                              @"Без денег сон крепче.",	@"Без ума голова - ногам пагуба.",
                              @"Белый заяц бел, да цена ему пятнадцать копеек.",	@"Береги бровь, - глаз цел будет.",
                              @"Бери в работе умом а не горбом.",	@"Бить дурака - жаль кулака."];
        for (NSString *proverb in proverbs) {
            Proverb *pr = [Proverb MR_createInContext:localContext];
            pr.text = proverb;
        }
    } completion:^(BOOL success, NSError *error) {
        [self createDefaultConnectionType];
    }];
}

- (void) createDefaultConnectionType {
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        ConnectionType *connectionType = [ConnectionType MR_createInContext:localContext];
        connectionType.name = @"LanguageStandartConnectionType";
        connectionType.id = @(sctLanguage);
    } completion:^(BOOL success, NSError *error) {
        [self createDefaultConnections];
    }];
}

- (void) createDefaultConnections {
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        for (int i = 0; i < 2; ++i) {
            Connection *connection = [Connection MR_createInContext:localContext];
            connection.name = (i == 0) ? @"Русский" : @"English";
            connection.id = @(i);
            connection.type = [[self standartConnectionTypes] valueForKey:[@(sctLanguage) stringValue]];
            if (!i) {
                NSArray *proverbs = [Proverb MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"self.id <= 6"]];//Пусть первые шесть будут русскими
                [connection addProverbs:[NSSet setWithArray:proverbs]];
            }
        }
    } completion:^(BOOL success, NSError *error) {
    }];
}

@end
