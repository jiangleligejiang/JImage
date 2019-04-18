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

@interface JImageDownloadToken : NSObject
@property (nonatomic, strong, nullable) id downloadToken;
@property (nonatomic, strong, nullable) NSURL *url;
@end

@interface JImageDownloader : NSObject

+ (instancetype)shareInstance;

- (nullable JImageDownloadToken *)fetchImageWithURL:(NSString *)url
                                            options:(JImageOptions)options
                                      progressBlock:(nullable JImageDownloadProgressBlock)progressBlock
                                    completionBlock:(nullable JImageDownloadCompletionBlock)completionBlock;

- (void)cancelWithToken:(JImageDownloadToken *)token;

@end

NS_ASSUME_NONNULL_END
