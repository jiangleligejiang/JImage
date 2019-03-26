//
//  ViewController.m
//  JImage
//
//  Created by Jams on 2019/3/22.
//  Copyright © 2019 jams. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "JImageDownloader.h"
#import "JImageCacheManager.h"
#import "MBProgressHUD+JUtils.h"
@interface ViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView = [[UIImageView alloc] init];
    self.imageView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.imageView];
    
    UIButton *downloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [downloadBtn setTitle:@"download" forState:UIControlStateNormal];
    [downloadBtn addTarget:self action:@selector(downloadImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:downloadBtn];
    
    UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [resetBtn setTitle:@"reset" forState:UIControlStateNormal];
    [resetBtn addTarget:self action:@selector(resetImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetBtn];
    
    UIButton *clearMemCacheBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [clearMemCacheBtn setTitle:@"clear memory cache" forState:UIControlStateNormal];
    [clearMemCacheBtn addTarget:self action:@selector(clearMemCache) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearMemCacheBtn];
    
    UIButton *clearDiskCacheBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [clearDiskCacheBtn setTitle:@"clear disk cache" forState:UIControlStateNormal];
    [clearDiskCacheBtn addTarget:self action:@selector(clearDiskCache) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearDiskCacheBtn];
    
    __weak typeof (self) weakSelf = self;
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(weakSelf.view);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    [downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.imageView.mas_bottom).offset(50);
        make.centerX.mas_equalTo(weakSelf.view.mas_centerX);
    }];
    [resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(downloadBtn.mas_bottom).offset(20);
        make.centerX.mas_equalTo(weakSelf.view.mas_centerX);
    }];
    [clearMemCacheBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(resetBtn.mas_bottom).offset(20);
        make.centerX.mas_equalTo(weakSelf.view.mas_centerX);
    }];
    [clearDiskCacheBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(clearMemCacheBtn.mas_bottom).offset(20);
        make.centerX.mas_equalTo(weakSelf.view.mas_centerX);
    }];
    
}

- (void)downloadImage {
    NSString *imageUrl = @"https://user-gold-cdn.xitu.io/2019/3/25/169b406dfc5fe46e";
    __weak typeof(self) weakSelf = self;
    [[JImageDownloader shareInstance] fetchImageWithURL:imageUrl completion:^(UIImage * _Nullable image, NSError * _Nullable error) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if (strongSelf && image) {
            strongSelf.imageView.image = image;
        }
    }];
}

- (void)resetImage {
    self.imageView.image = nil;
}

- (void)clearMemCache {
    [[JImageCacheManager shareManager] clearMemoryCache];
}

- (void)clearDiskCache {
    [[JImageCacheManager shareManager] clearDiskCache];
}

@end
