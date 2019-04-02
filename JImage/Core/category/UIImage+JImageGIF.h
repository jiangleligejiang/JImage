//
//  UIImage+JImageGIF.h
//  JImage
//
//  Created by liuqiang on 2019/4/2.
//  Copyright © 2019 jams. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (JImageGIF)
@property (nonatomic, copy) NSArray<UIImage *> *images;
@property (nonatomic, assign) NSInteger loopCount;
@property (nonatomic, copy) NSArray<NSNumber *> *delayTimes;
@property (nonatomic, assign) NSTimeInterval totalTimes;
@end

NS_ASSUME_NONNULL_END
