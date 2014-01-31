//
//  UIImageCache.m
//  LinkedProverbs
//
//  Created by Pavel Akhrameev on 31.01.14.
//  Copyright (c) 2014 Pavel Akhrameev. All rights reserved.
//

#import "UIImageCache.h"


@implementation UIImageCache {
    NSMutableDictionary *cache;
}

+ (instancetype) sharedInstance
{
    static UIImageCache *__sharedInstance= nil;
    static dispatch_once_t once_token = 0;
    dispatch_once(&once_token, ^
                  {
                      __sharedInstance =  [UIImageCache  new];
                  });
    return __sharedInstance ;
}

- (void) cacheImage:(UIImage *)image withName:(NSString *)name {
    NSAssert(image && name, @"Картинка и ключ должны быть заданы для добавления данных в кеш");
    if (!cache) {
        cache = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    [cache setObject:image forKey:name];
}

- (UIImage *) imageCachedWithName:(NSString *)name {
    return [cache valueForKey:name];
}

@end
