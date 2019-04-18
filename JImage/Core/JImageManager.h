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
#import "JImageOperation.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^JImageProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSURL *_Nullable targetURL);
typedef void(^JImageCompletionBlock)(UIImage * _Nullable image, NSError * _Nullable error, BOOL finished);
typedef UIImage *_Nullable(^JImageTransformBlock)(UIImage *image, NSString *_Nullable url);

typedef NS_ENUM(NSUInteger, JImageOptions) {
    JImageOptionProgressive = 1 << 0,
    JImageOptionIgnoreCache = 1 << 1,
    JImageOptionAvoidAutoSetImage = 1 << 2,
};

@interface JImageManager : NSObject
+ (instancetype)shareManager;

- (id<JImageOperation>)loadImageWithUrl:(NSString *)url
                                options:(JImageOptions)options
                               progress:(nullable JImageProgressBlock)progressBlock
                              transform:(nullable JImageTransformBlock)transformBlock
                             completion:(nullable JImageCompletionBlock)completionBlock;

- (void)setCacheConfig:(JImageCacheConfig *)cacheConfig;

- (void)setMemoryCache:(NSCache *)memoryCache;

- (void)setDiskCache:(id<JDiskCacheDelegate>)diskCache;

- (void)clearMemoryCache;

- (void)clearDiskCache;

@end

NS_ASSUME_NONNULL_END
