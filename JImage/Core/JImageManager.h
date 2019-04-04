//
//  JImageManager.h
//  JImage
//
//  Created by jams on 2019/4/2.
//  Copyright © 2019 jams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JImageCacheConfig.h"
#import "JDiskCacheDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface JImageManager : NSObject

+ (instancetype)shareManager;

- (void)loadImageWithUrl:(NSString *)url complection:(void(^)(UIImage * _Nullable image, NSError * _Nullable error))completionBlock;

- (void)setCacheConfig:(JImageCacheConfig *)cacheConfig;

- (void)setMemoryCache:(NSCache *)memoryCache;

- (void)setDiskCache:(id<JDiskCacheDelegate>)diskCache;

- (void)clearMemoryCache;

- (void)clearDiskCache;

@end

NS_ASSUME_NONNULL_END
