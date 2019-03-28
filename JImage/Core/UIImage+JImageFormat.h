//
//  UIImage+JImageFormat.h
//  JImage
//
//  Created by jams on 2019/3/27.
//  Copyright © 2019 jams. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, JImageFormat) {
    JImageFormatUndefined = -1,
    JImageFormatJPEG = 0,
    JImageFormatPNG = 1,
    JImageFormatGIF = 2
};
@interface UIImage (JImageFormat)
@property (nonatomic, assign) JImageFormat imageFormat;
@property (nonatomic, copy) NSArray *images;
@property (nonatomic, assign) NSInteger loopCount;
@property (nonatomic, copy) NSArray *delayTimes;
@property (nonatomic, assign) NSTimeInterval totalTimes;
@end

NS_ASSUME_NONNULL_END
