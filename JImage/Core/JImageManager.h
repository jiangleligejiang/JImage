//
//  JImageManager.h
//  JImage
//
//  Created by liuqiang on 2019/4/2.
//  Copyright © 2019 jams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JImageManager : NSObject

+ (instancetype)shareManager;

- (void)loadImageWithUrl:(NSString *)url complection:(void(^)(UIImage * _Nullable image, NSError * _Nullable error))completionBlock;

- (void)clearMemoryCache;

- (void)clearDiskCache;

@end

NS_ASSUME_NONNULL_END
