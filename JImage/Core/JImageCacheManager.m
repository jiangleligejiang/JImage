//
//  JImageCacheManager.m
//  JImage
//
//  Created by Jams on 2019/3/25.
//  Copyright © 2019 jams. All rights reserved.
//

#import "JImageCacheManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "JImageCoder.h"

@interface JImageCacheManager ()
@property (nonatomic, strong) NSCache *imageMemoryCache;
@property (nonatomic, copy) NSString *diskCachePath;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) dispatch_queue_t ioQueue;
@end

@implementation JImageCacheManager

+ (instancetype)shareManager {
    static JImageCacheManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JImageCacheManager alloc] init];
        [instance setup];
    });
    return instance;
}

- (void)setup {
    self.imageMemoryCache = [[NSCache alloc] init];
    self.fileManager = [NSFileManager new];
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    self.diskCachePath = [paths[0] stringByAppendingPathComponent:@"com.jimage.cache"];
    self.ioQueue = dispatch_queue_create("com.jimage.cache", DISPATCH_QUEUE_SERIAL);
}

- (void)queryImageCacheForKey:(NSString *)key completionBlock:(void(^)(UIImage * _Nullable, JImageCacheType))completionBlock{
    if (!key || key.length == 0) {
        completionBlock(nil, JImageCacheTypeNone);
        return;
    }
    
    UIImage *memoryCache = [self.imageMemoryCache objectForKey:key];
    if (memoryCache) {
        NSLog(@"image from memory cache");
        completionBlock(memoryCache, JImageCacheTypeMemory);
        return;
    }
    
    void(^queryDiskBlock)(void) = ^ {
        NSString *filepath = [self.diskCachePath stringByAppendingPathComponent:[self cachedFileNameForKey:key]];
        NSData *data = [NSData dataWithContentsOfFile:filepath];
        UIImage *diskCache = nil;
        JImageCacheType cacheType = JImageCacheTypeNone;
        if (data) {
            diskCache = [[JImageCoder shareCoder] decodeImageWithData:data];
            if (diskCache) {
                cacheType = JImageCacheTypeDisk;
                [self.imageMemoryCache setObject:diskCache forKey:key];
                NSLog(@"image from disk cache");
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(diskCache, cacheType);
        });
    };
    dispatch_async(self.ioQueue, queryDiskBlock);//加入到队列中异步处理
}

- (void)storeToMemoryWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image || !key || key.length == 0) {
        return;
    }
    [self.imageMemoryCache setObject:image forKey:key];
}

- (void)storeToDiskWithData:(NSData *)data forKey:(NSString *)key {
    if (!data || !key || key.length == 0) {
        return;
    }
    
    void(^storeDiskBlock)(void) = ^ {
        if (![self.fileManager fileExistsAtPath:self.diskCachePath]) {
            [self.fileManager createDirectoryAtPath:self.diskCachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *filePath = [self.diskCachePath stringByAppendingPathComponent:[self cachedFileNameForKey:key]];
        NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
        [data writeToURL:fileUrl atomically:YES];
    };
    dispatch_async(self.ioQueue, storeDiskBlock);
}

- (void)clearMemoryCache {
    [self.imageMemoryCache removeAllObjects];
    NSLog(@"clear memory cache success");
}

- (void)clearDiskCache {
    NSError *error;
    [self.fileManager removeItemAtPath:self.diskCachePath error:&error];
    if (error) {
        NSLog(@"clear disk cache fail:%@", error.description ? : @"");
    } else {
        NSLog(@"clear disk cache success");
    }
}

#pragma mark - util methods
- (BOOL)containsAlphaWithCGImage:(CGImageRef)imageRef {
    if (!imageRef) {
        return NO;
    }
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone || alphaInfo == kCGImageAlphaNoneSkipFirst || alphaInfo == kCGImageAlphaNoneSkipLast);
    return hasAlpha;
}

- (nullable NSString *)cachedFileNameForKey:(nullable NSString *)key {
    const char *str = key.UTF8String;
    if (str == NULL) {
        str = "";
    }
    unsigned char r[16];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSURL *keyURL = [NSURL URLWithString:key];
    NSString *ext = keyURL ? keyURL.pathExtension : key.pathExtension;
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], ext.length == 0 ? @"" : [NSString stringWithFormat:@".%@", ext]];
    return filename;
}

@end
