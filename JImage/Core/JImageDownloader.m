//
//  JImageDownloader.m
//  JImage
//
//  Created by Jams on 2019/3/25.
//  Copyright © 2019 jams. All rights reserved.
//

#import "JImageDownloader.h"
#import "JImageCacheManager.h"
#import "JImageCoder.h"

@interface JImageDownloader()
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSCache *imageCache;
@end

@implementation JImageDownloader

+ (instancetype)shareInstance {
    static JImageDownloader *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JImageDownloader alloc] init];
        [instance setup];
    });
    return instance;
}

- (void)setup {
    self.session = [NSURLSession sharedSession];
    self.imageCache = [[NSCache alloc] init];
}

- (void)fetchImageWithURL:(NSString *)url completion:(void (^)(UIImage * _Nullable, NSError * _Nullable))completionBlock {
    if (!url || url.length == 0) {
        return;
    }
    
    NSURL *URL = [NSURL URLWithString:url];
    if (!URL) {
        return;
    }
    
    [[JImageCacheManager shareManager] queryImageCacheForKey:url completionBlock:^(UIImage * _Nullable cacheImage, JImageCacheType cacheType) {
        if (cacheImage) {
            completionBlock(cacheImage, nil);
            return;
        }
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            UIImage *image = nil;
            if (!error && data) {
                [[JImageCacheManager shareManager] storeToDiskWithData:data forKey:url];
                image = [[JImageCoder shareCoder] decodeImageWithData:data];
                if (image) {
                    [[JImageCacheManager shareManager] storeToMemoryWithImage:image forKey:url];
                }
            }
            if (error) {
                NSLog(@"fetch image from net fail:%@", error.description ? : @"");
            } else {
                NSLog(@"image from network");
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                completionBlock(image, error);
            });
        }];
        [dataTask resume];
    }];
}

@end
