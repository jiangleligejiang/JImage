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

- (id<JImageOperation>)loadImageWithUrl:(NSString *)url progress:(JImageProgressBlock)progressBlock completion:(JImageCompletionBlock)completionBlock {
    __block JImageCombineOperation *combineOperation = [JImageCombineOperation new];
    combineOperation.url = url;
    combineOperation.cacheOperation =  [self.imageCache queryImageForKey:url cacheType:JImageCacheTypeAll completion:^(UIImage * _Nullable image, JImageCacheType cacheType) {
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                SAFE_CALL_BLOCK(completionBlock, image, nil);
            });
            NSLog(@"fetch image from %@", (cacheType == JImageCacheTypeMemory) ? @"memory" : @"disk");
            return;
        }
        
        JImageDownloadToken *downloadToken = [[JImageDownloader shareInstance] fetchImageWithURL:url progressBlock:progressBlock completionBlock:^(NSData * _Nullable imageData, NSError * _Nullable error, BOOL finished) {
            if (!imageData || error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    SAFE_CALL_BLOCK(completionBlock, nil, error);
                });
                return;
            }
            [[JImageCoder shareCoder] decodeImageWithData:imageData WithBlock:^(UIImage * _Nullable image) {
                [self.imageCache storeImage:image imageData:imageData forKey:url completion:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    SAFE_CALL_BLOCK(completionBlock, image, nil);
                });
            }];
        }];
        combineOperation.downloadToken = downloadToken;
    }];
    return combineOperation;
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
