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
        NSArray *proverbs = @[@"Муха села на варенье - вот и все стихотворенье", @"Бежал от дыма и упал в огонь.",
                              @"Без денег сон крепче.",	@"Без ума голова - ногам пагуба.",
                              @"Белый заяц бел, да цена ему пятнадцать копеек.",	@"Береги бровь, - глаз цел будет.",
                              @"Бери в работе умом а не горбом.",	@"Бить дурака - жаль кулака."];
        NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:proverbs.count];
        for (NSString *proverb in proverbs) {
            Proverb *pr = [Proverb MR_createEntity];
            pr.text = proverb;
            if (pr)
                [tmp addObject:pr];
        }
        results = tmp;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DAOProverbsUpdated object:results];
}

@end
