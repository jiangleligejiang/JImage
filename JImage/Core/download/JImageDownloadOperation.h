//
//  JImageDownloadOperation.h
//  JImage
//
//  Created by 刘强 on 2019/4/6.
//  Copyright © 2019 jams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JImageOperation.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^JImageDownloadProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSURL *_Nullable targetURL);
typedef void(^JImageDownloadCompletionBlock)(NSData *_Nullable imageData, NSError *_Nullable error, BOOL finished);
@interface JImageDownloadOperation : NSOperation <JImageOperation>

- (instancetype)initWithRequest:(NSURLRequest *)request;

- (id)addProgressHandler:(JImageDownloadProgressBlock)progressBlock withCompletionBlock:(JImageDownloadCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
