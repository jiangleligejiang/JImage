//
//  UIView+JImage.m
//  JImage
//
//  Created by jams on 2019/4/7.
//  Copyright © 2019 jams. All rights reserved.
//
#import "JImage.h"
#import "UIView+JImage.h"
#import "UIView+JImageOperation.h"
#import "UIImage+JImageFormat.h"
@implementation UIView (JImage)

- (void)setImageWithURL:(NSString *)url progressBlock:(JImageProgressBlock)progressBlock completionBlock:(JImageCompletionBlock)completionBlock {
    [self setImageWithURL:url placeHolder:nil progressBlock:progressBlock completionBlock:completionBlock];
}

- (void)setImageWithURL:(NSString *)url placeHolder:(UIImage *)placeHolder progressBlock:(JImageProgressBlock)progressBlock completionBlock:(JImageCompletionBlock)completionBlock {
    safe_dispatch_main_async(^{
        [self internalSetImage:placeHolder];
    });
    id<JImageOperation> operation = [[JImageManager shareManager] loadImageWithUrl:url progress:progressBlock completion:completionBlock];
    [self setOperation:operation forKey:NSStringFromClass([self class])];
}

- (void)setImageWithURL:(NSString *)url {
    [self setImageWithURL:url placeHolder:nil];
}

- (void)setImageWithURL:(NSString *)url placeHolder:(UIImage *)placeHolder {
    safe_dispatch_main_async(^{
        [self internalSetImage:placeHolder];
    });
    
    __weak typeof(self) weakSelf = self;
    id<JImageOperation> operation = [[JImageManager shareManager] loadImageWithUrl:url progress:nil completion:^(UIImage * _Nullable image, NSError * _Nullable error) {
        if (error) {
            NSLog(@"JImage Error:set image fail with url:%@, error:%@", url, error.description ? : @"");
        } else if (image) {
            [weakSelf internalSetImage:image];
        } else {
            NSLog(@"JImage Error:image is nil");
        }
    }];
    [self setOperation:operation forKey:NSStringFromClass([self class])];
}

- (void)internalSetImage:(UIImage *)image {
    if (!image) {
        return;
    }
    if ([self isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)self;
        if (image.imageFormat == JImageFormatGIF) {
            imageView.animationImages = image.images;
            imageView.animationDuration = image.totalTimes;
            imageView.animationRepeatCount = image.loopCount;
            [imageView startAnimating];
        } else {
            imageView.image = image;
        }
    } else if ([self isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)self;
        [button setImage:image forState:UIControlStateNormal];
    }
}

- (void)cancelLoadImage {
    [self cancelOperationForKey:NSStringFromClass([self class])];
}

@end
