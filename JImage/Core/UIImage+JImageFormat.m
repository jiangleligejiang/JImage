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

- (void)setTotalTimes:(NSTimeInterval)totalTimes {
    objc_setAssociatedObject(self, @selector(totalTimes), @(totalTimes), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)totalTimes {
    NSNumber *value = objc_getAssociatedObject(self, @selector(totalTimes));
    if ([value isKindOfClass:[NSNumber class]]) {
        return value.floatValue;
    }
    return 0;
}

- (void)setLoopCount:(NSInteger)loopCount {
    objc_setAssociatedObject(self, @selector(loopCount), @(loopCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)loopCount {
    NSNumber *value = objc_getAssociatedObject(self, @selector(loopCount));
    if ([value isKindOfClass:[NSNumber class]]) {
        return value.integerValue;
    }
    return 0;
}

- (void)setDelayTimes:(NSArray *)delayTimes {
    objc_setAssociatedObject(self, @selector(delayTimes), delayTimes, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSArray *)delayTimes {
    NSArray *delayTimes = objc_getAssociatedObject(self, @selector(delayTimes));
    if ([delayTimes isKindOfClass:[NSArray class]]) {
        return delayTimes;
    }
    return nil;
}

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