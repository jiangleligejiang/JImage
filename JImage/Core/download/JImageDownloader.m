//
//  JImageDownloader.m
//  JImage
//
//  Created by Jams on 2019/3/25.
//  Copyright © 2019 jams. All rights reserved.
//

#import "JImageDownloader.h"
#import "JImageCoder.h"

#define LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#define UNLOCK(lock) dispatch_semaphore_signal(lock);

@interface JImageDownloader()
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSMutableDictionary<NSURL *, JImageDownloadOperation *> *URLOperations;
@property (nonatomic, strong) dispatch_semaphore_t URLsLock;
@end

@implementation JImageDownloader

+ (instancetype)shareInstance {
    static JImageDownloader *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JImageDownloader alloc] init];
        [instance setup];
    });
    return instance;
}

- (void)setup {
    self.session = [NSURLSession sharedSession];
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.URLOperations = [NSMutableDictionary dictionary];
    self.URLsLock = dispatch_semaphore_create(1);
}

- (void)fetchImageWithURL:(NSString *)url progressBlock:(JImageDownloadProgressBlock)progressBlock completionBlock:(JImageDownloadCompletionBlock)completionBlock {
    if (!url || url.length == 0) {
        return;
    }
    
    NSURL *URL = [NSURL URLWithString:url];
    if (!URL) {
        return;
    }
    
    LOCK(self.URLsLock);
    JImageDownloadOperation *operation = [self.URLOperations objectForKey:URL];
    if (!operation || operation.isCancelled || operation.isFinished) {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL];
        operation = [[JImageDownloadOperation alloc] initWithRequest:request];
        __weak typeof(self) weakSelf = self;
        operation.completionBlock = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            LOCK(self.URLsLock);
            [strongSelf.URLOperations removeObjectForKey:URL];
            UNLOCK(self.URLsLock);
        };
        [self.operationQueue addOperation:operation];
        [self.URLOperations setObject:operation forKey:URL];
    }
    UNLOCK(self.URLsLock);
    [operation addProgressHandler:progressBlock withCompletionBlock:completionBlock];
    
}

@end
