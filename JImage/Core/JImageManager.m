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

- (void)loadImageWithUrl:(NSString *)url complection:(void (^)(UIImage * _Nullable, NSError * _Nullable))completionBlock {
    [self.imageCache queryImageForKey:url cacheType:JImageCacheTypeAll completion:^(UIImage * _Nullable image, JImageCacheType cacheType) {
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(image, nil);
            });
            NSLog(@"fetch image from %@", (cacheType == JImageCacheTypeMemory) ? @"memory" : @"disk");
            return;
        }
        
        [[JImageDownloader shareInstance] fetchImageWithURL:url completion:^(UIImage * _Nullable image, NSData *_Nullable data, NSError * _Nullable error) {
            [self.imageCache storeImage:image imageData:data forKey:url completion:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(image, error);
            });
        }];
    }];
}

- (void)setCacheConfig:(JImageCacheConfig *)cacheConfig {
    self.imageCache.cacheConfig = cacheConfig;
}

- (void)clearDiskCache {
    [self.imageCache clearAllWithCacheType:JImageCacheTypeDisk completion:nil];
}

- (void)clearMemoryCache {
    [self.imageCache clearAllWithCacheType:JImageCacheTypeMemory completion:nil];
}

@end
