//
//  JDiskCacheDelegate.h
//  JImage
//
//  Created by jams on 2019/4/4.
//  Copyright © 2019 jams. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JDiskCacheDelegate <NSObject>

- (void)storeImageData:(nullable NSData *)imageData
                forKey:(nullable NSString *)key;

- (nullable NSData *)queryImageDataForKey:(nullable NSString *)key;

- (BOOL)removeImageDataForKey:(nullable NSString *)key;

- (BOOL)containImageDataForKey:(nullable NSString *)key;

- (void)clearDiskCache;

- (void)deleteOldFiles;

@end

NS_ASSUME_NONNULL_END
