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

@property (nonatomic, assign) BOOL shouldCacheImagesInMemory; //是否使用内存缓存

@property (nonatomic, assign) BOOL shouldCacheImagesInDisk; //是否使用磁盘缓存

@property (nonatomic, assign) NSInteger maxCacheAge; //文件最大缓存时间

@property (nonatomic, assign) NSInteger maxCacheSize; //文件缓存最大限制

@end

NS_ASSUME_NONNULL_END
