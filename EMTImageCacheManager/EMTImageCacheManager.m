//
//  EMTImageCacheManager.m
//
//  Created by Hironobu Kimura on 2015/05/01.
//  Copyright (c) 2015 emotionale. All rights reserved.
//

#import "EMTImageCacheManager.h"

@implementation EMTImageCacheManager {
    NSMutableArray *keyInformations;
}

static EMTImageCacheManager *_instance = nil;

+ (instancetype)instance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[EMTImageCacheManager alloc] init];
    });
    return _instance;
}

- (void)prepareOrderedCacheInformations {
    if (!keyInformations) {
       keyInformations = [self getOrderedKeyInformations];
    }
}

- (NSMutableArray *)getOrderedKeyInformations {
    
    NSError *error = nil;
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"^cache([0-9.]+)_(.+)$" options:0 error:&error];
    
    NSMutableArray *keyInfos = [NSMutableArray array];
    NSDictionary *caches = [WKInterfaceDevice currentDevice].cachedImages;
    for (NSString *key in caches) {
        NSArray *matches = [regularExpression matchesInString:key options:0 range:NSMakeRange(0, [key length])];
        if ([matches count] != 0) {
            NSTextCheckingResult *result = (NSTextCheckingResult *)matches[0];
            NSString *dateString = [key substringWithRange:[result rangeAtIndex:1]];
            NSString *name = [key substringWithRange:[result rangeAtIndex:2]];
            NSDictionary *dict = @{ @"date":[NSDate dateWithTimeIntervalSince1970:[dateString doubleValue]], @"key":key, @"name":name };
            [keyInfos addObject:dict];
        }
    }
    
    NSArray *sortedKeyInfos = [keyInfos sortedArrayUsingComparator:^(id obj1, id obj2) {
                                return [obj1[@"date"] compare:obj2[@"date"]];
                                }];
    
    return [sortedKeyInfos mutableCopy];
}

- (NSString *)addOrderedCachedImageWithData:(NSData *)imageData name:(NSString *)name {

    if (!imageData || !name) return nil;
    
    [self prepareOrderedCacheInformations];
    
    [self removeOrderedCachedImageForName:name];
    
    NSString *key = [self saveOrderedCachedImageWithData:imageData name:name];
    if (key) {
        return key;
    }

    NSInteger dataSize = [imageData length];

    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    
    for (NSUInteger i = 0; i < [keyInformations count]; i++) {
        NSString *imageKeyToRemove = keyInformations[i][@"key"];
        NSNumber *num = [WKInterfaceDevice currentDevice].cachedImages[imageKeyToRemove];
        dataSize -= [num integerValue];
        [[WKInterfaceDevice currentDevice] removeCachedImageWithName:imageKeyToRemove];
        [indexes addIndex:i];
        if (dataSize <= 0) break;
    }
    if ([indexes count] != 0) {
        [keyInformations removeObjectsAtIndexes:indexes];
    }
    
    return [self saveOrderedCachedImageWithData:imageData name:name];
}

- (NSString *)getOrderedCacheKeyForName:(NSString *)name {
    
    [self prepareOrderedCacheInformations];
    
    NSInteger index = [self indexOfOrderdKeyWithName:name];
    if (index == -1) {
       return nil;
    }
    return keyInformations[index][@"key"];
}

- (NSString *)saveOrderedCachedImageWithData:(NSData *)imageData name:(NSString *)name {
    
    NSDate *date = [NSDate date];
    NSString *key = [NSString stringWithFormat:@"cache%f_%@", [date timeIntervalSince1970], name];
    
    if ([[WKInterfaceDevice currentDevice] addCachedImageWithData:imageData name:key]) {
        [keyInformations addObject:@{ @"date":date, @"key":key, @"name":name }];
        return key;
    }
    return nil;
}

- (NSInteger)indexOfOrderdKeyWithName:(NSString *)name {
    
    __block NSInteger index = -1;
    [keyInformations enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        if ([dict[@"name"] isEqualToString:name]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

- (void)removeOrderedCachedImageForName:(NSString *)name {
    
    [self prepareOrderedCacheInformations];
    
    NSInteger removeIndex = [self indexOfOrderdKeyWithName:name];
    if (removeIndex != -1) {
        [[WKInterfaceDevice currentDevice] removeCachedImageWithName:keyInformations[removeIndex][@"key"]];
        [keyInformations removeObjectAtIndex:removeIndex];
    }
}

- (void)removeAllOrderedCachedImage {
    
    [self prepareOrderedCacheInformations];
    
    [keyInformations enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        [[WKInterfaceDevice currentDevice] removeCachedImageWithName:dict[@"key"]];
    }];
    [keyInformations removeAllObjects];
}

@end
