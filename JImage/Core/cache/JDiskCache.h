//
//  JDiskCache.h
//  JImage
//
//  Created by jams on 2019/4/2.
//  Copyright © 2019 jams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JImageCacheConfig.h"
#import "JDiskCacheDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface JDiskCache : NSObject <JDiskCacheDelegate>

- (instancetype)initWithPath:(nullable NSString *)path withConfig:(nullable JImageCacheConfig *)config;

@end

NS_ASSUME_NONNULL_END
