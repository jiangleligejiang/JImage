//
//  UIImage+JImageFormat.m
//  JImage
//
//  Created by jams on 2019/3/27.
//  Copyright © 2019 jams. All rights reserved.
//

#import "UIImage+JImageFormat.h"
#import "objc/runtime.h"

@implementation UIImage (JImageFormat)

- (void)setImages:(NSArray *)images {
    objc_setAssociatedObject(self, @selector(images), images, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSArray *)images {
    NSArray *images = objc_getAssociatedObject(self, @selector(images));
    if ([images isKindOfClass:[NSArray class]]) {
        return images;
    }
    return nil;
}

- (void)setDuration:(NSTimeInterval)duration {
    objc_setAssociatedObject(self, @selector(duration), @(duration), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)duration {
    NSNumber *value = objc_getAssociatedObject(self, @selector(duration));
    if ([value isKindOfClass:[NSNumber class]]) {
        return value.floatValue;
    }
    return -1;
}

- (void)setLoopCount:(NSInteger)loopCount {
    objc_setAssociatedObject(self, @selector(loopCount), @(loopCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)loopCount {
    NSNumber *value = objc_getAssociatedObject(self, @selector(loopCount));
    if ([value isKindOfClass:[NSNumber class]]) {
        return value.integerValue;
    }
    return -1;
}

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

@end
