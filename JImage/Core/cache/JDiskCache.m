//
//  JDiskCache.m
//  JImage
//
//  Created by jams on 2019/4/2.
//  Copyright © 2019 jams. All rights reserved.
//

#import "JDiskCache.h"
#import <CommonCrypto/CommonDigest.h>

@interface JDiskCache ()
@property (nonatomic, copy) NSString *diskPath;
@property (nonatomic, strong) NSFileManager *fileManager;
@end

@implementation JDiskCache

- (instancetype)initWithPath:(NSString *)path {
    if (self = [super init]) {
        if (path) {
            self.diskPath = path;
        } else {
            self.diskPath = [self defaultDiskPath];
        }
        self.fileManager = [NSFileManager new];
    }
    return self;
}

- (void)storeImageData:(NSData *)imageData forKey:(NSString *)key {
    if (!imageData || !key || key.length == 0) {
        return;
    }
    
    if (![self.fileManager fileExistsAtPath:self.diskPath]) {
        [self.fileManager createDirectoryAtPath:self.diskPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [self.diskPath stringByAppendingPathComponent:[self cachedFileNameForKey:key]];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    [imageData writeToURL:fileURL atomically:YES];
}

- (BOOL)containImageDataForKey:(NSString *)key {
    if (!key || key.length == 0) {
        return NO;
    }
    
    NSString *filePath = [self filePathForKey:key];
    BOOL contained = [self.fileManager fileExistsAtPath:filePath];
    if (!contained) {
        contained = [self.fileManager fileExistsAtPath:filePath.stringByDeletingPathExtension];
    }
    return contained;
}

- (BOOL)removeImageDataForKey:(NSString *)key {
    if (!key || key.length == 0) {
        return NO;
    }
    
    NSString *filePath = [self filePathForKey:key];
    return [self.fileManager removeItemAtPath:filePath error:nil];
}

- (NSData *)queryImageDataForKey:(NSString *)key {
    if (!key || key.length == 0) {
        return nil;
    }
    
    NSString *filePath = [self filePathForKey:key];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    return data;
}


- (void)clearDiskCache {
    NSError *error;
    [self.fileManager removeItemAtPath:self.diskPath error:&error];
    if (error) {
        NSLog(@"clear disk cache fail: %@", error ? error.description : @"");
    }
}

- (NSString *)filePathForKey:(NSString *)key {
    return [self.diskPath stringByAppendingPathComponent:[self cachedFileNameForKey:key]];
}

- (NSString *)defaultDiskPath {
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingString:@"com.jimage.cache"];
}

- (NSString *)cachedFileNameForKey:(nullable NSString *)key {
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
