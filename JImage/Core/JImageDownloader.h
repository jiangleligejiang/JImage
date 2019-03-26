//
//  JImageDownloader.h
//  JImage
//
//  Created by Jams on 2019/3/25.
//  Copyright © 2019 jams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface JImageDownloader : NSObject

+ (instancetype)shareInstance;

- (void)fetchImageWithURL:(NSString *)url completion:(void(^)(UIImage * _Nullable image, NSError * _Nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END
