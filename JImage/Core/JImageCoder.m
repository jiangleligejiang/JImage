
//
//  JImageCoder.m
//  JImage
//
//  Created by jams on 2019/3/27.
//  Copyright © 2019 jams. All rights reserved.
//

#import "JImageCoder.h"

@implementation JImageCoder

+ (instancetype)shareCoder {
    static JImageCoder *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JImageCoder alloc] init];
    });
    return instance;
}

- (UIImage *)decodeImageWithData:(NSData *)data {
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
        //获取GIF中的循环次数
        CFDictionaryRef properties = CGImageSourceCopyProperties(source, NULL);
        if (properties) {
            CFDictionaryRef gif = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
            if (gif) {
                CFTypeRef loop = CFDictionaryGetValue(gif, kCGImagePropertyGIFLoopCount);
                if (loop) CFNumberGetValue(loop, kCFNumberNSIntegerType, &loopCount);
            }
            CFRelease(properties);
        }
        
        NSTimeInterval duration = 0;
        NSMutableArray<UIImage *> *imageArray = [NSMutableArray array];
        for (size_t i = 0; i < count; i ++) {
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
            if (!imageRef) {
                continue;
            }
            
            CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(source, i, NULL);
            if (properties) {
                NSTimeInterval currentDuration = 0;
                CFDictionaryRef gif = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
                if (gif) {
                    CFTypeRef value = NULL;
                    value = CFDictionaryGetValue(gif, kCGImagePropertyGIFUnclampedDelayTime);
                    if (!value) {
                        value = CFDictionaryGetValue(gif, kCGImagePropertyGIFDelayTime);
                    }
                    if (value) {
                        CFNumberGetValue(value, kCFNumberDoubleType, &currentDuration);
                        duration += currentDuration;
                    }
                }
                CFRelease(properties);
            }
            
            UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
            [imageArray addObject:image];
            
            CGImageRelease(imageRef);
        }
        
        animatedImage = [[UIImage alloc] init];
        animatedImage.imageFormat = JImageFormatGIF;
        animatedImage.loopCount = loopCount;
        animatedImage.duration = duration;
        animatedImage.images = [imageArray copy];
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
