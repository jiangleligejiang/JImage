//
//  JImageCacheConfig.h
//  JImage
//
//  Created by jams on 2019/4/2.
//  Copyright © 2019 jams. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JImageCacheConfig : NSObject

@property (nonatomic, assign) BOOL shouldDecompressImages;

@property (nonatomic, assign) BOOL shouldCacheImagesInMemory;

@property (nonatomic, assign) BOOL shouldCacheImagesInDisk;

@property (nonatomic, assign) NSInteger maxCacheAge;

@property (nonatomic, assign) NSInteger maxCacheSize;

@end

NS_ASSUME_NONNULL_END
