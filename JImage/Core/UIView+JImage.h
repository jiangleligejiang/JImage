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

- (void)setImageWithURL:(NSString *)url
          progressBlock:(JImageProgressBlock)progressBlock
        completionBlock:(JImageCompletionBlock)completionBlock;

- (void)setImageWithURL:(NSString *)url
            placeHolder:(UIImage *_Nullable)placeHolder
          progressBlock:(JImageProgressBlock)progressBlock
        completionBlock:(JImageCompletionBlock)completionBlock;

- (void)setImageWithURL:(NSString *)url;

- (void)setImageWithURL:(NSString *)url placeHolder:(UIImage * _Nullable)placeHolder;

- (void)cancelLoadImage;

@end

NS_ASSUME_NONNULL_END
