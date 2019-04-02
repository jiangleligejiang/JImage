//
//  UIImage+JImageFormat.m
//  JImage
//
//  Created by jams on 2019/3/27.
//  Copyright © 2019 jams. All rights reserved.
//

#import "UIImage+JImageFormat.h"
#import "objc/runtime.h"

FOUNDATION_STATIC_INLINE NSUInteger JImageMemoryCost(UIImage *image){
    NSUInteger imageSize = image.size.width * image.size.height * image.scale;
    return image.images ? imageSize * image.images.count : imageSize;
}

@implementation UIImage (JImageFormat)

- (UIImage *)normalizedImage {
    if (self.imageOrientation == UIImageOrientationUp) {
        return self;
    }
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

#pragma mark - associated object
- (void)setImageFormat:(JImageFormat)imageFormat {
    objc_setAssociatedObject(self, @selector(imageFormat), @(imageFormat), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (JImageFormat)imageFormat {
    JImageFormat imageFormat = JImageFormatUndefined;
    NSNumber *value = objc_getAssociatedObject(self, @selector(imageFormat));
    if ([value isKindOfClass:[NSNumber class]]) {
        imageFormat = value.integerValue;
        return imageFormat;
    }
    return imageFormat;
}

- (NSUInteger)memoryCost {
    NSNumber *value = objc_getAssociatedObject(self, @selector(memoryCost));
    if (value) {
        return [value unsignedIntegerValue];
    } else {
        NSUInteger memoryCost = JImageMemoryCost(self);
        [self setMemoryCost:memoryCost];
        return memoryCost;
    }
}

- (void)setMemoryCost:(NSUInteger)memoryCost {
    objc_setAssociatedObject(self, @selector(memoryCost), @(memoryCost), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



@end
