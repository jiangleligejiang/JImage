//
//  JImageCacheManager.h
//  JImage
//
//  Created by Jams on 2019/3/25.
//  Copyright © 2019 jams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, JImageCacheType) {
    JImageCacheTypeNone,
    JImageCacheTypeMemory,
    JImageCacheTypeDisk
};

@interface JImageCacheManager : NSObject

+ (instancetype)shareManager;

- (void)queryImageCacheForKey:(NSString *)key completionBlock:(void(^)(UIImage *_Nullable image, JImageCacheType cacheType))completionBlock;

- (void)storeImage:(UIImage *_Nullable)image forKey:(NSString *)key;

- (void)clearMemoryCache;

- (void)clearDiskCache;

@end

NS_ASSUME_NONNULL_END
