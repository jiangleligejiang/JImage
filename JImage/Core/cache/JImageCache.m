//
//  JImageCache.m
//  JImage
//
//  Created by jams on 2019/4/2.
//  Copyright © 2019 jams. All rights reserved.
//

#import "JImageCache.h"
#import "UIImage+JImageFormat.h"
#import "JImageCoder.h"

#define SAFE_CALL_BLOCK(blockFunc, ...)    \
    if (blockFunc) {                        \
        blockFunc(__VA_ARGS__);              \
    }


@interface JImageCache()
@property (nonatomic, strong) dispatch_queue_t ioQueue;
@property (nonatomic, strong, readwrite) JMemoryCache *memoryCache;
@property (nonatomic, strong, readwrite) JDiskCache *diskCache;
@end

@implementation JImageCache

#pragma mark - init
- (instancetype)init {
    return [self initWithNameSpace:@"default"];
}

- (instancetype)initWithNameSpace:(NSString *)nameSpace {
    return [self initWithNameSpace:nameSpace diskDirectoryPath:[self diskPathWithNameSpace:nameSpace]];
}

- (instancetype)initWithNameSpace:(NSString *)nameSpace diskDirectoryPath:(NSString *)directory {
    if (self = [super init]) {
        NSString *fullNameSpace = [@"com.jimage.cache" stringByAppendingString:nameSpace];
        NSString *diskPath;
        if (directory) {
            diskPath = [directory stringByAppendingPathComponent:fullNameSpace];
        } else {
            diskPath = [[self diskPathWithNameSpace:nameSpace] stringByAppendingString:fullNameSpace];
        }
        self.cacheConfig = [[JImageCacheConfig alloc] init];
        self.diskCache = [[JDiskCache alloc] initWithPath:diskPath withConfig:self.cacheConfig];
        self.memoryCache = [[NSCache alloc] init];
        self.ioQueue = dispatch_queue_create("com.jimage.cache", DISPATCH_QUEUE_SERIAL);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - public method
- (void)storeImage:(UIImage *)image imageData:(NSData *)imageData forKey:(NSString *)key completion:(void (^)(void))completionBlock {
    if (!key || key.length == 0 || (!image && !imageData)) {
        SAFE_CALL_BLOCK(completionBlock);
        return;
    }
    void(^storeBlock)(void) = ^ {
        if (self.cacheConfig.shouldCacheImagesInMemory) {
            if (image) {
                [self.memoryCache setObject:image forKey:key cost:image.memoryCost];
            } else if (imageData) {
                UIImage *decodedImage = [[JImageCoder shareCoder] decodeImageWithData:imageData];
                [self.memoryCache setObject:decodedImage forKey:key cost:decodedImage.memoryCost];
            }
        }
        if (self.cacheConfig.shouldCacheImagesInDisk) {
            if (imageData) {
                [self.diskCache storeImageData:imageData forKey:key];
            } else if (image) {
                NSData *data = [[JImageCoder shareCoder] encodedDataWithImage:image];
                if (data) {
                    [self.diskCache storeImageData:data forKey:key];
                }
            }
        }
        SAFE_CALL_BLOCK(completionBlock);
    };
    dispatch_async(self.ioQueue, storeBlock);
}

- (void)queryImageForKey:(NSString *)key cacheType:(JImageCacheType)cacheType completion:(void (^)(UIImage * _Nullable, JImageCacheType))completionBlock {
    if (!key || key.length == 0) {
        SAFE_CALL_BLOCK(completionBlock, nil, JImageCacheTypeNone);
        return;
    }
    void(^queryBlock)(void) = ^ {
        UIImage *image = nil;
        JImageCacheType cacheFrom = cacheType;
        if (cacheType == JImageCacheTypeMemory) {
            image = [self.memoryCache objectForKey:key];
        } else if (cacheType == JImageCacheTypeDisk) {
            NSData *data = [self.diskCache queryImageDataForKey:key];
            if (data) {
                image = [[JImageCoder shareCoder] decodeImageWithData:data];
            }
        } else if (cacheType == JImageCacheTypeAll) {
            image = [self.memoryCache objectForKey:key];
            cacheFrom = JImageCacheTypeMemory;
            if (!image) {
                NSData *data = [self.diskCache queryImageDataForKey:key];
                if (data) {
                    cacheFrom = JImageCacheTypeDisk;
                    image = [[JImageCoder shareCoder] decodeImageWithData:data];
                    [self.memoryCache setObject:image forKey:key cost:image.memoryCost];
                }
            }
        }
        SAFE_CALL_BLOCK(completionBlock, image, cacheFrom);
    };
    dispatch_async(self.ioQueue, queryBlock);
}

- (void)containImageWithKey:(NSString *)key cacheType:(JImageCacheType)cacheType completion:(void (^)(BOOL))completionBlock {
    if (!key || key.length == 0) {
        SAFE_CALL_BLOCK(completionBlock, NO);
        return;
    }
    
    void(^diskContainedBlock)(void) = ^ {
        BOOL contained = [self.diskCache containImageDataForKey:key];
        SAFE_CALL_BLOCK(completionBlock, contained);
    };
    
    if (cacheType == JImageCacheTypeMemory) {
        BOOL contained = ([self.memoryCache objectForKey:key] != nil);
        SAFE_CALL_BLOCK(completionBlock, contained);
    } else if (cacheType == JImageCacheTypeDisk) {
        dispatch_async(self.ioQueue, diskContainedBlock);
    } else if (cacheType == JImageCacheTypeAll) {
        BOOL contained = ([self.memoryCache objectForKey:key] != nil);
        if (contained) {
            SAFE_CALL_BLOCK(completionBlock, contained);
        } else {
            dispatch_async(self.ioQueue, diskContainedBlock);
        }
    } else {
        SAFE_CALL_BLOCK(completionBlock, NO);
    }
}

- (void)removeImageForKey:(NSString *)key cacheType:(JImageCacheType)cacheType completion:(void (^)(void))completionBlock {
    if (!key || key.length == 0) {
        SAFE_CALL_BLOCK(completionBlock);
        return;
    }
    
    void(^diskRemovedBlock)(void) = ^{
        [self.diskCache removeImageDataForKey:key];
        SAFE_CALL_BLOCK(completionBlock);
    };
    
    if (cacheType == JImageCacheTypeMemory) {
        [self.memoryCache removeObjectForKey:key];
        SAFE_CALL_BLOCK(completionBlock);
    } else if (cacheType == JImageCacheTypeDisk) {
        dispatch_async(self.ioQueue, diskRemovedBlock);
    } else if (cacheType == JImageCacheTypeAll) {
        [self.memoryCache removeObjectForKey:key];
        dispatch_async(self.ioQueue, diskRemovedBlock);
    } else {
        SAFE_CALL_BLOCK(completionBlock);
    }
}

- (void)clearAllWithCacheType:(JImageCacheType)cacheType completion:(void (^)(void))completionBlock {
    if (cacheType == JImageCacheTypeMemory) {
        [self.memoryCache removeAllObjects];
    } else if (cacheType == JImageCacheTypeDisk) {
        dispatch_async(self.ioQueue, ^{
            [self.diskCache clearDiskCache];
            SAFE_CALL_BLOCK(completionBlock);
        });
    } else if (cacheType == JImageCacheTypeAll) {
        [self.memoryCache removeAllObjects];
        dispatch_async(self.ioQueue, ^{
            [self.diskCache clearDiskCache];
            SAFE_CALL_BLOCK(completionBlock);
        });
    }
}

#pragma mark - backgournd task

- (void)onDidEnterBackground:(NSNotification *)notification {
    [self backgroundDeleteOldFiles];
}

- (void)backgroundDeleteOldFiles {
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    void(^deleteBlock)(void) = ^ {
        [self.diskCache deleteOldFiles];
        dispatch_async(dispatch_get_main_queue(), ^{
            [application endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        });
    };
    
    dispatch_async(self.ioQueue, deleteBlock);
}

#pragma mark - private method
- (NSString *)diskPathWithNameSpace:(NSString *)namespace {
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:namespace];
}
@end
