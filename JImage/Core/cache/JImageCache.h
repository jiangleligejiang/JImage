//
//  JImageCache.h
//  JImage
//
//  Created by jams on 2019/4/2.
//  Copyright © 2019 jams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDiskCache.h"
#import "JImageCacheConfig.h"


typedef NS_ENUM(NSInteger, JImageCacheType) {
    JImageCacheTypeNone = 0,
    JImageCacheTypeMemory = 1 << 0,
    JImageCacheTypeDisk = 1 << 1,
    JImageCacheTypeAll = JImageCacheTypeMemory | JImageCacheTypeDisk
};

typedef NSCache JMemoryCache;

NS_ASSUME_NONNULL_BEGIN
@interface JImageCache : NSObject

@property (nonatomic, strong) JDiskCache *diskCache;
@property (nonatomic, strong) JMemoryCache *memoryCache;
@property (nonatomic, strong) JImageCacheConfig *cacheConfig;

- (instancetype)initWithNameSpace:(nullable NSString *)nameSpace;

- (instancetype)initWithNameSpace:(nullable NSString *)nameSpace
                diskDirectoryPath:(nullable NSString *)directory;

- (void)storeImage:(nullable UIImage *)image
         imageData:(nullable NSData *)imageData
            forKey:(nullable NSString *)key
        completion:(nullable void(^)(void))completionBlock;

- (void)queryImageForKey:(nullable NSString *)key
               cacheType:(JImageCacheType)cacheType
              completion:(nullable void(^)(UIImage *_Nullable image, JImageCacheType cacheType))completionBlock;

- (void)containImageWithKey:(nullable NSString *)key
                   cacheType:(JImageCacheType)cacheType
                  completion:(nullable void(^)(BOOL contained))completionBlock;

- (void)removeImageForKey:(nullable NSString *)key
                cacheType:(JImageCacheType)cacheType
               completion:(nullable void(^)(void))completionBlock;

- (void)clearAllWithCacheType:(JImageCacheType)cacheType
                   completion:(nullable void(^)(void))completionBlock;

@end

NS_ASSUME_NONNULL_END
