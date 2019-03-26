//
//  MBProgressHUD.m
//  JImage
//
//  Created by Jams on 2019/3/25.
//  Copyright © 2019 jams. All rights reserved.
//

#import "MBProgressHUD+JUtils.h"

@implementation MBProgressHUD (JUtils)

+ (void)showGlobalHUDWithTitle:(NSString *)title {
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.label.text = title;
    hud.offset = CGPointMake(0, -100);
    hud.mode = MBProgressHUDModeText;
    [hud hideAnimated:YES afterDelay:2.0];
}

@end
