//
//  UIView+JImage.m
//  JImage
//
//  Created by 刘强 on 2019/4/7.
//  Copyright © 2019 jams. All rights reserved.
//

#import "UIView+JImage.h"
#import "UIView+JImageOperation.h"
#import "UIImage+JImageFormat.h"
@implementation UIView (JImage)

- (void)setImageWithURL:(NSString *)url progressBlock:(JImageProgressBlock)progressBlock completionBlock:(JImageCompletionBlock)completionBlock {
    id<JImageOperation> operation = [[JImageManager shareManager] loadImageWithUrl:url progress:progressBlock completion:completionBlock];
    [self setOperation:operation forKey:NSStringFromClass([self class])];
}

- (void)setImageWithURL:(NSString *)url {
    __weak typeof(self) weakSelf = self;
    id<JImageOperation> operation = [[JImageManager shareManager] loadImageWithUrl:url progress:nil completion:^(UIImage * _Nullable image, NSError * _Nullable error) {
        if (error) {
            NSLog(@"set image fail with url:%@, error:%@", url, error.description ? : @"");
        } else if (image) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if ([self isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)strongSelf;
                if (image.imageFormat == JImageFormatGIF) {
                    imageView.animationImages = image.images;
                    imageView.animationDuration = image.totalTimes;
                    imageView.animationRepeatCount = image.loopCount;
                    [imageView startAnimating];
                } else {
                    imageView.image = image;
                }
            } else if ([self isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)strongSelf;
                [button setImage:image forState:UIControlStateNormal];
            }
        }
    }];
    [self setOperation:operation forKey:NSStringFromClass([self class])];
}

- (void)cancelLoadImage {
    [self cancelOperationForKey:NSStringFromClass([self class])];
}

@end
