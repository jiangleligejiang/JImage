//
//  JImageCoderHelper.h
//  JImage
//
//  Created by jams on 2019/4/18.
//  Copyright © 2019 jams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImage+JImageFormat.h"
NS_ASSUME_NONNULL_BEGIN

@interface JImageCoderHelper : NSObject

+ (JImageFormat)imageFormatWithData:(NSData *)data;

+ (UIImageOrientation)imageOrientationFromEXIFOrientation:(NSInteger)exifOrientation;

@end

NS_ASSUME_NONNULL_END
