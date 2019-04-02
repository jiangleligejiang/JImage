//
//  JDiskCache.h
//  JImage
//
//  Created by jams on 2019/4/2.
//  Copyright © 2019 jams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JDiskCache : NSObject

- (instancetype)initWithPath:(nullable NSString *)path;

- (void)storeImageData:(nullable NSData *)imageData
            forKey:(nullable NSString *)key;

- (nullable NSData *)queryImageDataForKey:(nullable NSString *)key;

- (BOOL)removeImageDataForKey:(nullable NSString *)key;

- (BOOL)containImageDataForKey:(nullable NSString *)key;

- (void)clearDiskCache;

@end

NS_ASSUME_NONNULL_END