//
//  NormalAlertView.h
//  SealClass
//
//  Created by liyan on 2019/3/12.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ButtonBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface NormalAlertView : UIView

+ (void)showAlertWithTitle:(NSString *)title  confirmTitle:(NSString *)confirmTitle  confirm:(ButtonBlock)confirm;

+ (void)showAlertWithTitle:(NSString *)title  leftTitle:(NSString *)leftTitle rightTitle:(NSString *)rightTitle  cancel:(ButtonBlock)cancel confirm:(ButtonBlock)confirm;

@end

NS_ASSUME_NONNULL_END
