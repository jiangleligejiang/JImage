//
//  JImageManager.m
//  JImage
//
//  Created by jams on 2019/4/2.
//  Copyright © 2019 jams. All rights reserved.
//

#import "JImageManager.h"
#import "JImageCache.h"
#import "JImageDownloader.h"
#import "JImageCoder.h"
#import "JImageOperation.h"
#import "JImage.h"

#define SAFE_CALL_BLOCK(blockFunc, ...)    \
    if (blockFunc) {                        \
        blockFunc(__VA_ARGS__);              \
    }

@interface JImageCombineOperation : NSObject <JImageOperation>
@property (nonatomic, strong) NSOperation *cacheOperation;
@property (nonatomic, strong) JImageDownloadToken* downloadToken;
@property (nonatomic, copy) NSString *url;
@end

@implementation JImageCombineOperation

- (void)cancelOperation {
    NSLog(@"cancel operation for url:%@", self.url ? : @"");
    if (self.cacheOperation) {
        [self.cacheOperation cancel];
    }
    if (self.downloadToken) {
        [[JImageDownloader shareInstance] cancelWithToken:self.downloadToken];
    }
}

@end


@interface JImageManager ()
@property (nonatomic, strong) JImageCache *imageCache;
@end

@implementation JImageManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static JImageManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[JImageManager alloc] init];
        [instance setup];
    });
    return instance;
}

- (void)setup {
    self.imageCache = [[JImageCache alloc] init];
}

- (id<JImageOperation>)loadImageWithUrl:(NSString *)url options:(JImageOptions)options progress:(JImageProgressBlock)progressBlock transform:(JImageTransformBlock)transformBlock completion:(JImageCompletionBlock)completionBlock {
    __block JImageCombineOperation *combineOperation = [JImageCombineOperation new];
    combineOperation.url = url;
    if (options & JImageOptionIgnoreCache) {
        combineOperation.downloadToken = [self fetchImageWithUrl:url options:options progressBlock:progressBlock transformBlock:transformBlock completionBlock:completionBlock];
    } else {
        combineOperation.cacheOperation =  [self.imageCache queryImageForKey:url cacheType:JImageCacheTypeAll completion:^(UIImage * _Nullable image, JImageCacheType cacheType) {
            if (image) {
                safe_dispatch_main_async(^{
                    SAFE_CALL_BLOCK(completionBlock, image, nil);
                });
                NSLog(@"JImage Error:fetch image from %@", (cacheType == JImageCacheTypeMemory) ? @"memory" : @"disk");
            } else {
                combineOperation.downloadToken = [self fetchImageWithUrl:url options:options progressBlock:progressBlock transformBlock:transformBlock completionBlock:completionBlock];
            }
        }];
    }
    return combineOperation;
}

- (JImageDownloadToken *)fetchImageWithUrl:(NSString *)url options:(JImageOptions)options progressBlock:(JImageProgressBlock)progressBlock transformBlock:(JImageTransformBlock)transformBlock completionBlock:(JImageCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    JImageDownloadToken *downloadToken = [[JImageDownloader shareInstance] fetchImageWithURL:url progressBlock:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        safe_dispatch_main_async(^{
            SAFE_CALL_BLOCK(progressBlock, receivedSize, expectedSize, targetURL);
        });
    } completionBlock:^(NSData * _Nullable imageData, NSError * _Nullable error, BOOL finished) {
        if (!imageData || error) {
            safe_dispatch_main_async(^{
                SAFE_CALL_BLOCK(completionBlock, nil, error);
            });
            return;
        }
        [[JImageCoder shareCoder] decodeImageWithData:imageData WithBlock:^(UIImage * _Nullable image) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            UIImage *transformImage = image;
            if (transformBlock) {
                transformImage = transformBlock(image, url);
            }
            [strongSelf.imageCache storeImage:transformImage imageData:imageData forKey:url completion:nil];
            safe_dispatch_main_async(^{
                SAFE_CALL_BLOCK(completionBlock, transformImage, nil);
            });
        }];
    }];
    return downloadToken;
}

- (void)clearDiskCache {
    [self.imageCache clearAllWithCacheType:JImageCacheTypeDisk completion:nil];
}

- (void)clearMemoryCache {
    [self.imageCache clearAllWithCacheType:JImageCacheTypeMemory completion:nil];
}

#pragma mark - setter
- (void)setCacheConfig:(JImageCacheConfig *)cacheConfig {
    self.imageCache.cacheConfig = cacheConfig;
}

- (void)setMemoryCache:(NSCache *)memoryCache {
    self.imageCache.memoryCache = memoryCache;
}

- (void)setDiskCache:(id<JDiskCacheDelegate>)diskCache {
    self.imageCache.diskCache = diskCache;
}

@end
