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
            if (type)
                return [self connectionsOfType:type];
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
            [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
                ConnectionType *connectionType = [ConnectionType MR_createInContext:localContext];
                connectionType.name = @"LanguageStandartConnectionType";
                connectionType.id = @(sctLanguage);
                if (connectionType) {
                    [mdicInBlock setValue:connectionType forKey:[@(sctLanguage) stringValue]];
                }
            } completion:^(BOOL success, NSError *error) {
                __stdConnectionTypes = mdicInBlock;
            }];
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
            NSLog(@"%@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:DAOProverbsUpdated object:results];
        }];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DAOProverbsUpdated object:results];
}

@end
