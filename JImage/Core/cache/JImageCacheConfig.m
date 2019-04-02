//
//  JImageCacheConfig.m
//  JImage
//
//  Created by jams on 2019/4/2.
//  Copyright © 2019 jams. All rights reserved.
//

#import "JImageCacheConfig.h"

static const NSInteger kDefaultMaxCacheAge = 60 * 60 * 24 * 7;
@implementation JImageCacheConfig

- (instancetype)init {
    if (self = [super init]) {
        self.shouldDecompressImages = YES;
        self.shouldCacheImagesInDisk = YES;
        self.shouldCacheImagesInMemory = YES;
        self.maxCacheAge = kDefaultMaxCacheAge;
        self.maxCacheSize = NSIntegerMax;
    }
    return self;
}

@end
