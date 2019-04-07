//
//  JImageDownloader.h
//  JImage
//
//  Created by Jams on 2019/3/25.
//  Copyright © 2019 jams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JImageDownloadOperation.h"

NS_ASSUME_NONNULL_BEGIN
@interface JImageDownloader : NSObject

+ (instancetype)shareInstance;

- (void)fetchImageWithURL:(NSString *)url completion:(void(^)(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error))completionBlock;

- (void)fetchImageWithURL:(NSString *)url
           progressBlock:(nullable JImageDownloadProgressBlock)progressBlock
         completionBlock:(nullable JImageDownloadCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
