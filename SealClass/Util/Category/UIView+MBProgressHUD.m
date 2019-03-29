//
//  UIView+MBProgressHUD.m
//  SealClass
//
//  Created by liyan on 2019/3/12.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "UIView+MBProgressHUD.h"

#define MBPHUD_EXECUTE(...) \
__weak typeof(self) weakself = self; \
[self hideHUDCompletion:^{ \
[weakself.HUD removeFromSuperview]; \
__VA_ARGS__ \
}];

CGFloat const MBPHUDFontSize = 12;
CGFloat const MBPHUDShowTime = 5.0f;

@implementation UIView (MBProgressHUD)

@dynamic HUD;

- (MBProgressHUD *)HUD {
    return [MBProgressHUD HUDForView:self];
}

- (MBProgressHUD *)instanceHUD {
    MBProgressHUD *HUD = [[MBProgressHUD alloc]initWithView:self];
    [self setupHUD:HUD];
    return HUD;
}

- (void)showHUDMessage:(NSString *)message {
    MBPHUD_EXECUTE({
        MBProgressHUD *HUD = [weakself instanceHUD];
        [weakself addSubview:HUD];
        [weakself bringSubviewToFront:HUD];
        HUD.mode = MBProgressHUDModeText;
        HUD.label.text = message;
        [HUD showAnimated:YES];
        [HUD hideAnimated:YES afterDelay:MBPHUDShowTime];
    })
}

- (void)hideHUDCompletion:(nullable void(^)(void))completion {
    if (!self.HUD) { if (completion) completion(); return; }
    self.HUD.completionBlock = completion;
    [self.HUD hideAnimated:YES];
}

- (void)setupHUD:(MBProgressHUD *)HUD {
    HUD.removeFromSuperViewOnHide = YES;
    HUD.userInteractionEnabled = NO;
    HUD.square = NO;
    HUD.offset = CGPointMake(0, (- (UIScreenHeight / 2 - 64 - 17)));
    HUD.margin = 7;
    HUD.bezelView.color = [UIColor colorWithHexString:@"070809" alpha:1];
    HUD.bezelView.layer.cornerRadius = 14;
    HUD.contentColor = [UIColor colorWithHexString:@"FFFFFF" alpha:1];
    HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    HUD.label.font = [UIFont systemFontOfSize:MBPHUDFontSize];
    HUD.label.numberOfLines = 3;
}


@end
