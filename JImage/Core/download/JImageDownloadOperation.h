//
//  JImageDownloadOperation.h
//  JImage
//
//  Created by jams on 2019/4/6.
//  Copyright © 2019 jams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JImageOperation.h"
#import "JImageManager.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^JImageDownloadProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSURL *_Nullable targetURL);
typedef void(^JImageDownloadCompletionBlock)(UIImage *_Nullable image, NSData *_Nullable imageData, NSError *_Nullable error, BOOL finished);
@interface JImageDownloadOperation : NSOperation <JImageOperation>

- (instancetype)initWithRequest:(NSURLRequest *)request options:(JImageOptions)options;

- (id)addProgressHandler:(JImageDownloadProgressBlock)progressBlock withCompletionBlock:(JImageDownloadCompletionBlock)completionBlock;

- (BOOL)cancelWithToken:(id)token;

@end

NS_ASSUME_NONNULL_END
