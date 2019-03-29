//
//  InputTextField.m
//  SealClass
//
//  Created by 张改红 on 2019/3/4.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "InputTextField.h"

@implementation InputTextField
- (instancetype)init{
    self = [super init];
    if (self) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 20;
        [self setBorderState:(InputTextFieldBorderStateNormal)];
        self.layer.borderWidth = 1;
        self.returnKeyType = UIReturnKeyDone;
    }
    return self;
}

#pragma mark - API
- (void)setBorderState:(InputTextFieldBorderState)state{
    if (state == InputTextFieldBorderStateNormal) {
        self.layer.borderColor = HEXCOLOR(0xDCE1E0).CGColor;
    }else if (state == InputTextFieldBorderStateEditing) {
        self.layer.borderColor = HEXCOLOR(0x21C194).CGColor;
    }else if (state == InputTextFieldBorderStateError) {
        self.layer.borderColor = HEXCOLOR(0xF44436).CGColor;
    }
}

#pragma mark - super method
- (CGRect)textRectForBounds:(CGRect)bounds{
    return CGRectMake(20, 0, bounds.size.width-35, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds{
    return CGRectMake(20, 0, bounds.size.width-35, bounds.size.height);
}

- (UILabel *)warnLabel{
    if (!_warnLabel) {
        _warnLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.frame)+20,CGRectGetMaxY(self.frame), self.frame.size.width-20, 16)];
        _warnLabel.font = [UIFont systemFontOfSize:12];
        _warnLabel.textColor = HEXCOLOR(0xf44436);
        _warnLabel.hidden = YES;
        [self.superview addSubview:_warnLabel];
    }
    return _warnLabel;
}
@end
