//
//  RCCRInputView.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/11.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "InputView.h"

@interface InputView () <UITextViewDelegate>

@end

@implementation InputView
//  初始化
- (id)initWithStatus:(InputBarControlStatus)status {
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self initializedSubViews];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [_inputContainerView setFrame:self.bounds];
    CGFloat space = 0;
    if (frame.size.width == [UIScreen mainScreen].bounds.size.width) {
        space = [self getIphoneXFitSpace];
    }
    [_emojiButton setFrame:CGRectMake(10+space, 10, 25, 25)];
    [_inputTextView setFrame:CGRectMake(CGRectGetMaxX(self.emojiButton.frame)+11, 7, self.bounds.size.width - (CGRectGetMaxX(self.emojiButton.frame)+11+CGRectGetMaxX(self.emojiButton.frame)), 36)];
}

- (CGFloat)getIphoneXFitSpace{
    static CGFloat space;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 11.0, *)) {
            UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
            UIEdgeInsets safeAreaInsets = mainWindow.safeAreaInsets;
            if (!UIEdgeInsetsEqualToEdgeInsets(safeAreaInsets,UIEdgeInsetsZero)){
                space = 34;
            }
        }});
    return space;
}

#pragma mark <UITextViewDelegate>
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([self.delegate respondsToSelector:@selector(inputTextView:shouldChangeTextInRange:replacementText:)]) {
        [self.delegate inputTextView:textView shouldChangeTextInRange:range replacementText:text];
    }
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didTouchKeyboardReturnKey:text:)]) {
            NSString *_needToSendText = textView.text;
            NSString *_formatString =
            [_needToSendText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (0 == [_formatString length]) {
                
            } else {
                //  发送点击事件
                [self.delegate didTouchKeyboardReturnKey:self text:[_needToSendText copy]];
            }
        }
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidChange:)]) {
        [self.delegate inputTextViewDidChange:textView];
    }
}

- (void)didTapTextView{
    self.emojiButton.selected = NO;
    [self.inputTextView setInputView:nil];
    [self.inputTextView reloadInputViews];
    [self.inputTextView becomeFirstResponder];
}

- (void)didTouchEmojiDown:(UIButton *)sender {
    [_emojiButton setSelected:!sender.selected];
    [self.delegate didTouchEmojiButton:sender];
}

- (void)clearInputText {
    [_inputTextView setText:@""];
}

- (void)initializedSubViews {
    [self addSubview:self.inputContainerView];
    [_inputContainerView addSubview:self.inputTextView];
    [_inputContainerView addSubview:self.emojiButton];
}

#pragma mark - UI

- (UIView *)inputContainerView {
    if (!_inputContainerView) {
        _inputContainerView = [[UIView alloc] init];
        [_inputContainerView setBackgroundColor:[UIColor clearColor]];
    }
    return _inputContainerView;
}

- (UITextView *)inputTextView {
    if (!_inputTextView) {
        _inputTextView = [[UITextView alloc] init];
        [_inputTextView setTextColor:[UIColor blackColor]];
        [_inputTextView setFont:[UIFont systemFontOfSize:16]];
        _inputTextView.backgroundColor = HEXCOLOR(0xffffff);
        [_inputTextView setReturnKeyType:UIReturnKeySend];
        [_inputTextView setEnablesReturnKeyAutomatically:YES];  //内容为空，返回按钮不可点击
        [_inputTextView.layer setCornerRadius:6];
        [_inputTextView.layer setMasksToBounds:YES];
        [_inputTextView.layer setBorderWidth:0.5f];
        [_inputTextView.layer setBorderColor:HEXCOLOR(0xb2b2b2).CGColor];
        [_inputTextView.layoutManager setAllowsNonContiguousLayout:YES];    //默认从顶部开始显示
        [_inputTextView setDelegate:self];
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTextView)];
        [_inputTextView addGestureRecognizer:tapGes];

    }
    return _inputTextView;
}

- (UIButton *)emojiButton {
    if (!_emojiButton) {
        _emojiButton = [[UIButton alloc] init];
        [_emojiButton setImage:[UIImage imageNamed:@"icon_emoji_default"] forState:UIControlStateNormal];
        [_emojiButton setImage:[UIImage imageNamed:@"icon_emoji_pressed"] forState:UIControlStateHighlighted];
        [_emojiButton setExclusiveTouch:YES];
        [_emojiButton addTarget:self action:@selector(didTouchEmojiDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emojiButton;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
