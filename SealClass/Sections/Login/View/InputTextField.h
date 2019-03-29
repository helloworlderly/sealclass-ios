//
//  InputTextField.h
//  SealClass
//
//  Created by 张改红 on 2019/3/4.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, InputTextFieldBorderState) {
    InputTextFieldBorderStateNormal = 0,
    InputTextFieldBorderStateEditing,
    InputTextFieldBorderStateError,
};

@interface InputTextField : UITextField
@property (nonatomic, strong) UILabel *warnLabel;
- (void)setBorderState:(InputTextFieldBorderState)state;
@end

NS_ASSUME_NONNULL_END
