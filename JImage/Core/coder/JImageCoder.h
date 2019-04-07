//
//  JImageCoder.h
//  JImage
//
//  Created by jams on 2019/3/27.
//  Copyright © 2019 jams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIImage+JImageFormat.h"

NS_ASSUME_NONNULL_BEGIN

@interface JImageCoder : NSObject

+ (instancetype)shareCoder;

- (nullable UIImage *)decodeImageSyncWithData:(nullable NSData *)data;

- (nullable NSData *)encodedDataSyncWithImage:(nullable UIImage *)image;

- (void)decodeImageWithData:(NSData *)data WithBlock:(void(^)(UIImage *_Nullable image))completionBlock;

- (void)encodedDataWithImage:(UIImage *)image WithBlock:(void(^)(NSData *_Nullable data))completionBlock;

@end

NS_ASSUME_NONNULL_END
