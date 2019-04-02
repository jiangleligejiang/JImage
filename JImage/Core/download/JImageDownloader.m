//
//  JImageDownloader.m
//  JImage
//
//  Created by Jams on 2019/3/25.
//  Copyright © 2019 jams. All rights reserved.
//

#import "JImageDownloader.h"
#import "JImageCoder.h"

@interface JImageDownloader()
@property (nonatomic, strong) NSURLSession *session;
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
}

- (void)fetchImageWithURL:(NSString *)url completion:(void (^)(UIImage * _Nullable, NSData * _Nullable data, NSError * _Nullable))completionBlock {
    if (!url || url.length == 0) {
        return;
    }
    
    NSURL *URL = [NSURL URLWithString:url];
    if (!URL) {
        return;
    }
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UIImage *image = nil;
        if (!error && data) {
            image = [[JImageCoder shareCoder] decodeImageWithData:data];
        }
        if (error) {
            NSLog(@"fetch image from net fail:%@", error.description ? : @"");
        } else {
            NSLog(@"image from network");
        }
        completionBlock(image, data, error);
    }];
    [dataTask resume];
}

@end
