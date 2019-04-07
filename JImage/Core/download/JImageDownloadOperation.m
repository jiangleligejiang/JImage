//
//  JImageDownloadOperation.m
//  JImage
//
//  Created by 刘强 on 2019/4/6.
//  Copyright © 2019 jams. All rights reserved.
//

#import "JImageDownloadOperation.h"

#define LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#define UNLOCK(lock) dispatch_semaphore_signal(lock);
typedef NSMutableDictionary<NSString *, id> JImageCallbackDictionary;
static NSString *const kImageProgressCallback = @"kImageProgressCallback";
static NSString *const kImageCompletionCallback = @"kImageCompletionCallback";

@interface JImageDownloadOperation() <NSURLSessionDataDelegate, NSURLSessionTaskDelegate>
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSMutableArray *callbacks;
@property (nonatomic, strong) dispatch_semaphore_t callbacksLock;
@property (nonatomic, assign, getter=isFinished) BOOL finished;
@property (nonatomic, assign) NSInteger expectedSize;
@property (nonatomic, strong) NSMutableData *imageData;
@end

@implementation JImageDownloadOperation
@synthesize finished = _finished;

- (instancetype)initWithRequest:(NSURLRequest *)request {
    if (self = [super init]) {
        self.request = request;
        self.callbacks = [NSMutableArray new];
        self.callbacksLock = dispatch_semaphore_create(1);
    }
    return self;
}

#pragma mark - callbacks
- (id)addProgressHandler:(JImageDownloadProgressBlock)progressBlock withCompletionBlock:(JImageDownloadCompletionBlock)completionBlock {
    LOCK(self.callbacksLock);
    JImageCallbackDictionary *callback = [NSMutableDictionary new];
    [callback setObject:progressBlock forKey:kImageProgressCallback];
    [callback setObject:completionBlock forKey:kImageCompletionCallback];
    [self.callbacks addObject:callback];
    UNLOCK(self.callbacksLock);
    return callback;
}

- (nullable NSArray *)callbacksForKey:(NSString *)key {
    LOCK(self.callbacksLock);
    NSMutableArray *callbacks = [[self.callbacks valueForKey:key] mutableCopy];
    UNLOCK(self.callbacksLock);
    [callbacks removeObject:[NSNull null]];
    return [callbacks copy];
}

#pragma mark - NSOperation
- (void)start {
    if (self.isCancelled) {
        self.finished = YES;
        [self reset];
        return;
    }
    
    if (!self.session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    self.dataTask = [self.session dataTaskWithRequest:self.request];
    [self.dataTask resume];
    
    for (JImageDownloadProgressBlock progressBlock in [self callbacksForKey:kImageProgressCallback]){
        progressBlock(0, NSURLResponseUnknownLength, self.request.URL);
    }
}

- (void)cancel {
    if (self.finished) {
        return;
    }
    [super cancel];
    if (self.dataTask) {
        [self.dataTask cancel];
    }
    [self reset];
}

- (void)reset {
    LOCK(self.callbacksLock);
    [self.callbacks removeAllObjects];
    UNLOCK(self.callbacksLock);
    
    self.dataTask = nil;
    if (self.session) {
        [self.session invalidateAndCancel];
        self.session = nil;
    }
}

- (void)done {
    self.finished = YES;
    [self reset];
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSInteger expectedSize = (NSInteger)response.expectedContentLength;
    self.expectedSize = expectedSize > 0 ? expectedSize : 0;
    for (JImageDownloadProgressBlock progressBlock in [self callbacksForKey:kImageProgressCallback]) {
        progressBlock(0, self.expectedSize, self.request.URL);
    }
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (!self.imageData) {
        self.imageData = [[NSMutableData alloc] initWithCapacity:self.expectedSize];
    }
    [self.imageData appendData:data];
    for (JImageDownloadProgressBlock progressBlock in [self callbacksForKey:kImageProgressCallback]) {
        progressBlock(self.imageData.length, self.expectedSize, self.request.URL);
    }
}

#pragma mark - NSURLSessionTaskDelgate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    for (JImageDownloadCompletionBlock completionBlock in [self callbacksForKey:kImageCompletionCallback]) {
        completionBlock([self.imageData copy], error, YES);
    }
    [self done];
}

#pragma mark - JImageOperation
- (void)cancelOperation {
    [self cancel];
}

#pragma mark - setter
- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

@end
