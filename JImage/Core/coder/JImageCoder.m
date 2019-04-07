
//
//  JImageCoder.m
//  JImage
//
//  Created by jams on 2019/3/27.
//  Copyright © 2019 jams. All rights reserved.
//

#import "JImageCoder.h"
#import <MobileCoreServices/MobileCoreServices.h>
static const NSTimeInterval kJAnimatedImageDelayTimeIntervalMinimum = 0.02;
static const NSTimeInterval kJAnimatedImageDefaultDelayTimeInterval = 0.1;

FOUNDATION_EXTERN_INLINE CFStringRef getImageUTType(JImageFormat imageFormat) {
    switch (imageFormat) {
        case JImageFormatPNG:
            return kUTTypePNG;
        case JImageFormatJPEG:
            return kUTTypeJPEG;
        case JImageFormatGIF:
            return kUTTypeGIF;
        default:
            return kUTTypePNG;
    }
}

FOUNDATION_EXTERN_INLINE BOOL JCGImageRefContainsAlpha(CGImageRef imageRef) {
    if (!imageRef) {
        return NO;
    }
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    return hasAlpha;
}

@interface JImageCoder ()
@property (nonatomic, strong) dispatch_queue_t coderQueue;
@end

@implementation JImageCoder

+ (instancetype)shareCoder {
    static JImageCoder *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JImageCoder alloc] init];
        [instance setup];
    });
    return instance;
}

- (void)setup {
    self.coderQueue = dispatch_queue_create("com.jimage.coder.queue", DISPATCH_QUEUE_SERIAL);
}

#pragma mark - encode
- (void)encodedDataWithImage:(UIImage *)image WithBlock:(void (^)(NSData * _Nullable))completionBlock {
    dispatch_async(self.coderQueue, ^{
        NSData *data = [self encodedDataSyncWithImage:image];
        completionBlock(data);
    });
}

- (NSData *)encodedDataSyncWithImage:(UIImage *)image {
    if (!image) {
        return nil;
    }
    switch (image.imageFormat) {
        case JImageFormatPNG:
        case JImageFormatJPEG:
            return [self encodedDataWithImage:image imageFormat:image.imageFormat];
            
        case JImageFormatGIF:{
            return [self encodedGIFDataWithImage:image];
        }

        case JImageFormatUndefined:{
            if (JCGImageRefContainsAlpha(image.CGImage)) {
                return [self encodedDataWithImage:image imageFormat:JImageFormatPNG];
            } else {
                return [self encodedDataWithImage:image imageFormat:JImageFormatJPEG];
            }
        }
    }
}

- (nullable NSData *)encodedDataWithImage:(UIImage *)image imageFormat:(JImageFormat)imageFormat {
    UIImage *fixedImage = [image normalizedImage];
    if (imageFormat == JImageFormatPNG) {
        return UIImagePNGRepresentation(fixedImage);
    } else {
        return UIImageJPEGRepresentation(fixedImage, 1.0);
    }
}

- (nullable NSData *)encodedGIFDataWithImage:(UIImage *)image {
    NSMutableData *gifData = [NSMutableData data];
    
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)gifData, kUTTypeGIF, image.images.count, NULL);
    if (!imageDestination) {
        return nil;
    }
    if (image.images.count == 0) {
        CGImageDestinationAddImage(imageDestination, image.CGImage, nil);
    } else {
        NSUInteger loopCount = image.loopCount;
        NSDictionary *gifProperties = @{(__bridge NSString *)kCGImagePropertyGIFDictionary : @{(__bridge NSString *)kCGImagePropertyGIFLoopCount : @(loopCount)}};
        CGImageDestinationSetProperties(imageDestination, (__bridge CFDictionaryRef)gifProperties);
        size_t count = MIN(image.images.count, image.delayTimes.count);
        for (size_t i = 0; i < count; i ++) {
            NSDictionary *properties = @{(__bridge NSString *)kCGImagePropertyGIFDictionary : @{(__bridge NSString *)kCGImagePropertyGIFDelayTime : image.images[i]}};
            CGImageDestinationAddImage(imageDestination, image.images[i].CGImage, (__bridge CFDictionaryRef)properties);
        }
    }
    if (CGImageDestinationFinalize(imageDestination) == NO) {
        gifData = nil;
    }
    CFRelease(imageDestination);
    return [gifData copy];
}


#pragma mark - decode
- (void)decodeImageWithData:(NSData *)data WithBlock:(void (^)(UIImage * _Nullable))completionBlock {
    dispatch_async(self.coderQueue, ^{
        UIImage *image = [self decodeImageSyncWithData:data];
        completionBlock(image);
    });
}

- (UIImage *)decodeImageSyncWithData:(NSData *)data {
    JImageFormat format = [self imageFormatWithData:data];
    switch (format) {
        case JImageFormatJPEG:
        case JImageFormatPNG:{
            UIImage *image = [[UIImage alloc] initWithData:data];
            image.imageFormat = format;
            return image;
        }
        case JImageFormatGIF:
            return [self decodeGIFWithData:data];
        default:
            return nil;
    }
}

- (UIImage *)decodeGIFWithData:(NSData *)data {
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    if (!source) {
        return nil;
    }
    size_t count = CGImageSourceGetCount(source);
    UIImage *animatedImage;
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
        animatedImage.imageFormat = JImageFormatGIF;
    } else {
        NSInteger loopCount = 0;
        CFDictionaryRef properties = CGImageSourceCopyProperties(source, NULL);
        if (properties) {
            CFDictionaryRef gif = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
            if (gif) {
                CFTypeRef loop = CFDictionaryGetValue(gif, kCGImagePropertyGIFLoopCount);
                if (loop) {
                    CFNumberGetValue(loop, kCFNumberNSIntegerType, &loopCount);
                }
            }
            CFRelease(properties);
        }
        
        NSMutableArray<NSNumber *> *delayTimeArray = [NSMutableArray array];
        NSMutableArray<UIImage *> *imageArray = [NSMutableArray array];
        NSTimeInterval duration = 0;
        for (size_t i = 0; i < count; i ++) {
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
            if (!imageRef) {
                continue;
            }
            
            UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
            [imageArray addObject:image];
            CGImageRelease(imageRef);
            
            float delayTime = kJAnimatedImageDefaultDelayTimeInterval;
            CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(source, i, NULL);
            if (properties) {
                CFDictionaryRef gif = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
                if (gif) {
                    CFTypeRef value = CFDictionaryGetValue(gif, kCGImagePropertyGIFUnclampedDelayTime);
                    if (!value) {
                        value = CFDictionaryGetValue(gif, kCGImagePropertyGIFDelayTime);
                    }
                    if (value) {
                        CFNumberGetValue(value, kCFNumberFloatType, &delayTime);
                        if (delayTime < ((float)kJAnimatedImageDelayTimeIntervalMinimum - FLT_EPSILON)) {
                            delayTime = kJAnimatedImageDefaultDelayTimeInterval;
                        }
                    }
                }
                CFRelease(properties);
            }
            duration += delayTime;
            [delayTimeArray addObject:@(delayTime)];
        }
        
        animatedImage = [[UIImage alloc] init];
        animatedImage.imageFormat = JImageFormatGIF;
        animatedImage.images = [imageArray copy];
        animatedImage.delayTimes = [delayTimeArray copy];
        animatedImage.loopCount = loopCount;
        animatedImage.totalTimes = duration;
    }
    CFRelease(source);
    return animatedImage;
}

#pragma mark - util methods
- (JImageFormat)imageFormatWithData:(NSData *)data {
    if (!data) {
        return JImageFormatUndefined;
    }
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return JImageFormatJPEG;
        case 0x89:
            return JImageFormatPNG;
        case 0x47:
            return JImageFormatGIF;
        default:
            return JImageFormatUndefined;
    }
}

@end
