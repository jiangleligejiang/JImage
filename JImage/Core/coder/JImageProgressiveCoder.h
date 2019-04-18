//
//  JImageProgressiveCoder.h
//  JImage
//
//  Created by jams on 2019/4/18.
//  Copyright © 2019 jams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JImageProgressiveCoder : NSObject

- (UIImage *)progressiveDecodedImageWithData:(NSData *)data finished:(BOOL)finished;

@end

NS_ASSUME_NONNULL_END
