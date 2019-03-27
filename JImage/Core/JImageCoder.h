//
//  JImageCoder.h
//  JImage
//
//  Created by jams on 2019/3/27.
//  Copyright © 2019 jams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIImage+JImageFormat.h"

NS_ASSUME_NONNULL_BEGIN

@interface JImageCoder : NSObject

+ (instancetype)shareCoder;

- (UIImage *)decodeImageWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
