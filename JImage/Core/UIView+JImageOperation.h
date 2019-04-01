//
//  UIView+JImageOperation.h
//  JImage
//
//  Created by jams on 2019/4/1.
//  Copyright © 2019 jams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JImageOperation.h"
NS_ASSUME_NONNULL_BEGIN

@interface UIView (JImageOperation)

- (void)setOperation:(id<JImageOperation>)operation forKey:(nullable NSString *)key;

- (void)cancelOperationForKey:(nullable NSString *)key;

- (void)removeOperationForKey:(nullable NSString *)key;

@end

NS_ASSUME_NONNULL_END
