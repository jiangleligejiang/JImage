//
//  JImageCoderHelper.m
//  JImage
//
//  Created by jams on 2019/4/18.
//  Copyright © 2019 jams. All rights reserved.
//

#import "JImageCoderHelper.h"

@implementation JImageCoderHelper

+ (JImageFormat)imageFormatWithData:(NSData *)data {
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

+ (UIImageOrientation)imageOrientationFromEXIFOrientation:(NSInteger)exifOrientation {
    UIImageOrientation imageOrientation = UIImageOrientationUp;
    switch (exifOrientation) {
        case 1:
            imageOrientation = UIImageOrientationUp;
            break;
        case 3:
            imageOrientation = UIImageOrientationDown;
            break;
        case 8:
            imageOrientation = UIImageOrientationLeft;
            break;
        case 6:
            imageOrientation = UIImageOrientationRight;
            break;
        case 2:
            imageOrientation = UIImageOrientationUpMirrored;
            break;
        case 4:
            imageOrientation = UIImageOrientationDownMirrored;
            break;
        case 5:
            imageOrientation = UIImageOrientationLeftMirrored;
            break;
        case 7:
            imageOrientation = UIImageOrientationRightMirrored;
            break;
        default:
            break;
    }
    return imageOrientation;
}

@end
