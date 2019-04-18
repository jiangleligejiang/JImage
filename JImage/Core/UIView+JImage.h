//
//  UIView+JImage.h
//  JImage
//
//  Created by jams on 2019/4/7.
//  Copyright © 2019 jams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JImageManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (JImage)

- (void)setImageWithURL:(nullable NSString *)url
          progressBlock:(nullable JImageProgressBlock)progressBlock
         transformBlock:(nullable JImageTransformBlock)transformBlock
        completionBlock:(nullable JImageCompletionBlock)completionBlock;

- (void)setImageWithURL:(nullable NSString *)url
            placeHolder:(nullable UIImage *)placeHolder
          progressBlock:(nullable JImageProgressBlock)progressBlock
         transformBlock:(nullable JImageTransformBlock)transformBlock
        completionBlock:(nullable JImageCompletionBlock)completionBlock;

- (void)setImageWithURL:(nullable NSString *)url;

- (void)setImageWithURL:(nullable NSString *)url placeHolder:(nullable UIImage *)placeHolder;

- (void)cancelLoadImage;

@end

NS_ASSUME_NONNULL_END
