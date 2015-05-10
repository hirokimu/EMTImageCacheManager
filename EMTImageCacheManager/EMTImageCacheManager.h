//
//  EMTImageCacheManager.h
//
//  Created by Hironobu Kimura on 2015/05/01.
//  Copyright (c) 2015 emotionale. All rights reserved.
//

#import <WatchKit/WatchKit.h>

@interface EMTImageCacheManager : NSObject

+ (instancetype)instance;
- (void)prepareOrderedCacheInformations;
- (NSString *)addOrderedCachedImageWithData:(NSData *)imageData name:(NSString *)name;
- (NSString *)getOrderedCacheKeyForName:(NSString *)name;
- (void)removeOrderedCachedImageForName:(NSString *)name;
- (void)removeAllOrderedCachedImage;

@end
