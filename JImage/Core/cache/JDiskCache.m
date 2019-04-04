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
@property (nonatomic, assign) NSInteger maxCacheAge;
@property (nonatomic, assign) NSInteger maxCacheSize;
@end

@implementation JDiskCache

- (instancetype)initWithPath:(NSString *)path withConfig:(JImageCacheConfig *)config{
    if (self = [super init]) {
        if (path) {
            self.diskPath = path;
        } else {
            self.diskPath = [self defaultDiskPath];
        }
        if (config) {
            self.maxCacheAge = config.maxCacheAge;
            self.maxCacheSize = config.maxCacheSize;
        } else {
            self.maxCacheSize = NSIntegerMax;
            self.maxCacheAge = NSIntegerMax;
        }
        self.fileManager = [NSFileManager new];
    }
    return self;
}

#pragma mark - public method

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

- (void)deleteOldFiles {
    NSLog(@"start clean up old files");
    NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskPath isDirectory:YES];
    NSArray<NSString *> *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentAccessDateKey, NSURLTotalFileAllocatedSizeKey];
    NSDirectoryEnumerator *fileEnumerator = [self.fileManager enumeratorAtURL:diskCacheURL includingPropertiesForKeys:resourceKeys options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:NULL];
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];
    NSMutableArray <NSURL *> *deleteURLs = [NSMutableArray array];
    NSMutableDictionary<NSURL *, NSDictionary<NSString *, id>*> *cacheFiles = [NSMutableDictionary dictionary];
    NSInteger currentCacheSize = 0;
    for (NSURL *fileURL in fileEnumerator) {
        NSError *error;
        NSDictionary<NSString *, id> *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:&error];
        if (error || !resourceValues || [resourceValues[NSURLIsDirectoryKey] boolValue]) {
            continue;
        }
        NSDate *accessDate = resourceValues[NSURLContentAccessDateKey];
        if ([accessDate earlierDate:expirationDate]) {
            [deleteURLs addObject:fileURL];
            continue;
        }
        
        NSNumber *fileSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
        currentCacheSize += fileSize.unsignedIntegerValue;
        [cacheFiles setObject:resourceValues forKey:fileURL];
    }
    
    for (NSURL *URL in deleteURLs) {
        NSLog(@"delete old file: %@", URL.absoluteString);
        [self.fileManager removeItemAtURL:URL error:nil];
    }
    
    if (self.maxCacheSize > 0 && currentCacheSize > self.maxCacheSize) {
        NSUInteger desiredCacheSize = self.maxCacheSize / 2;
        NSArray<NSURL *> *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1[NSURLContentAccessDateKey] compare:obj2[NSURLContentAccessDateKey]];
        }];
        for (NSURL *fileURL in sortedFiles) {
            if ([self.fileManager removeItemAtURL:fileURL error:nil]) {
                NSDictionary<NSString *, id> *resourceValues = cacheFiles[fileURL];
                NSNumber *fileSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                currentCacheSize -= fileSize.unsignedIntegerValue;
                
                if (currentCacheSize < desiredCacheSize) {
                    break;
                }
            }
        }
    }
}


#pragma mark - private method
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
