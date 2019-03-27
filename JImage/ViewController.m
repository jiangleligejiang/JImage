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
#import "UIImage+JImageFormat.h"
#import "YYWebImage.h"
#import "FLAnimatedImageView+WebCache.h"
@interface ViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) YYAnimatedImageView *yyImageView;
@property (nonatomic, strong) FLAnimatedImageView *sdImageView;
@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView = [[UIImageView alloc] init];
    self.imageView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.imageView];
    
    self.yyImageView = [[YYAnimatedImageView alloc] init];
    self.yyImageView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.yyImageView];
    
    self.sdImageView = [[FLAnimatedImageView alloc] init];
    self.sdImageView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.sdImageView];
    
    UILabel *yyLabel = [self labelWithTitle:@"YY Image"];
    [self.view addSubview:yyLabel];
    UILabel *sdLabel = [self labelWithTitle:@"SDWebImage"];
    [self.view addSubview:sdLabel];
    UILabel *customLabel = [self labelWithTitle:@"Custom Image"];
    [self.view addSubview:customLabel];
    
    UIButton *downloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [downloadBtn setTitle:@"Custom Load" forState:UIControlStateNormal];
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
    
    UIButton *yyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [yyBtn setTitle:@"YYImage Load" forState:UIControlStateNormal];
    [yyBtn addTarget:self action:@selector(yy_load) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:yyBtn];
    
    UIButton *sdBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [sdBtn setTitle:@"SDWebImage Load" forState:UIControlStateNormal];
    [sdBtn addTarget:self action:@selector(sd_load) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sdBtn];
    
    __weak typeof (self) weakSelf = self;
    [self.yyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.view.mas_centerX);
        make.top.mas_equalTo(weakSelf.view).offset(80);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    
    [self.sdImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.view.mas_centerX);
        make.top.mas_equalTo(weakSelf.yyImageView.mas_bottom).offset(20);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.view.mas_centerX);
        make.top.mas_equalTo(weakSelf.sdImageView.mas_bottom).offset(20);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    
    [yyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.yyImageView.mas_centerY);
        make.left.mas_equalTo(weakSelf.yyImageView.mas_right).offset(20);
    }];
    [sdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.sdImageView.mas_centerY);
        make.left.mas_equalTo(weakSelf.sdImageView.mas_right).offset(20);
    }];
    [customLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.imageView.mas_centerY);
        make.left.mas_equalTo(weakSelf.imageView.mas_right).offset(20);
    }];
    
    [yyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.imageView.mas_bottom).offset(20);
        make.centerX.mas_equalTo(weakSelf.view.mas_centerX);
    }];
    [sdBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(yyBtn.mas_bottom).offset(10);
        make.centerX.mas_equalTo(weakSelf.view.mas_centerX);
    }];
    [downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(sdBtn.mas_bottom).offset(10);
        make.centerX.mas_equalTo(weakSelf.view.mas_centerX);
    }];
    [resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(downloadBtn.mas_bottom).offset(10);
        make.centerX.mas_equalTo(weakSelf.view.mas_centerX);
    }];
    [clearMemCacheBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(resetBtn.mas_bottom).offset(10);
        make.centerX.mas_equalTo(weakSelf.view.mas_centerX);
    }];
    [clearDiskCacheBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(clearMemCacheBtn.mas_bottom).offset(10);
        make.centerX.mas_equalTo(weakSelf.view.mas_centerX);
    }];
}

- (UILabel *)labelWithTitle:(NSString *)title {
    UILabel *label = [UILabel new];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:14];
    label.text = title;
    return label;
}


static NSString *gifUrl = @"https://user-gold-cdn.xitu.io/2019/3/27/169bce612ee4dc21";
- (void)downloadImage {
    //NSString *imageUrl = @"https://user-gold-cdn.xitu.io/2019/3/25/169b406dfc5fe46e";
    __weak typeof(self) weakSelf = self;
    [[JImageDownloader shareInstance] fetchImageWithURL:gifUrl completion:^(UIImage * _Nullable image, NSError * _Nullable error) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if (strongSelf && image) {
            if (image.imageFormat == JImageFormatGIF) {
                strongSelf.imageView.animationImages = image.images;
                [strongSelf.imageView startAnimating];
            }
        }
    }];
}

- (void)resetImage {
    if (self.imageView.isAnimating) {
        [self.imageView stopAnimating];
    }
    self.imageView.image = nil;
    
    if (self.yyImageView.isAnimating) {
        [self.yyImageView stopAnimating];
    }
    self.yyImageView.image = nil;
    
    if (self.sdImageView.isAnimating) {
        [self.sdImageView stopAnimating];
    }
    self.sdImageView.image = nil;
}

- (void)clearMemCache {
    [[JImageCacheManager shareManager] clearMemoryCache];
}

- (void)clearDiskCache {
    [[JImageCacheManager shareManager] clearDiskCache];
}

- (void)yy_load {
    [self.yyImageView yy_setImageWithURL:[NSURL URLWithString:gifUrl] options:YYWebImageOptionProgressive];
}

- (void)sd_load {
    [self.sdImageView sd_setImageWithURL:[NSURL URLWithString:gifUrl]];
}


@end
