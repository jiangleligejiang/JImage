//
//  JImageProgressiveCoder.m
//  JImage
//
//  Created by jams on 2019/4/18.
//  Copyright © 2019 jams. All rights reserved.
//

#import "JImageProgressiveCoder.h"
#import "UIImage+JImageFormat.h"
#import "JImageCoderHelper.h"

@implementation JImageProgressiveCoder {
    size_t _width, _height;
    UIImageOrientation _orientation;
    CGImageSourceRef _imageSource;
}

- (void)dealloc {
    if (_imageSource) {
        CFRelease(_imageSource);
        _imageSource = NULL;
    }
}

- (UIImage *)progressiveDecodedImageWithData:(NSData *)data finished:(BOOL)finished {
    if (!_imageSource) {
        _imageSource = CGImageSourceCreateIncremental(NULL);
    }
    
    UIImage *image;
    CGImageSourceUpdateData(_imageSource, (__bridge CFDataRef)data, finished);
    if (_width + _height == 0) {
        CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(_imageSource, 0, NULL);
        if (properties) {
            NSInteger orientationValue = 1;
            CFTypeRef val = CFDictionaryGetValue(properties, kCGImagePropertyPixelHeight);
            if (val) CFNumberGetValue(val, kCFNumberLongType, &_height);
            val = CFDictionaryGetValue(properties, kCGImagePropertyPixelWidth);
            if (val) CFNumberGetValue(val, kCFNumberLongType, &_width);
            val = CFDictionaryGetValue(properties, kCGImagePropertyOrientation);
            if (val) CFNumberGetValue(val, kCFNumberNSIntegerType, &orientationValue);
            CFRelease(properties);
            _orientation = [JImageCoderHelper imageOrientationFromEXIFOrientation:orientationValue];
        }
    }
    
    if (_width + _height > 0) {
        CGImageRef partialImageRef = CGImageSourceCreateImageAtIndex(_imageSource, 0, NULL);
        if (partialImageRef) {
            image = [[UIImage alloc] initWithCGImage:partialImageRef scale:1 orientation:_orientation];
            CFRelease(partialImageRef);
            image.imageFormat = [JImageCoderHelper imageFormatWithData:data];
        }
    }
    
    if (finished) {
        if (_imageSource) {
            CFRelease(_imageSource);
            _imageSource = NULL;
        }
    }
    return image;
}

@end
