//
//  RCCRInputBar.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/10.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "InputBarControl.h"
#import "InputView.h"
#import "EmojiBoardView.h"

#define HeightEmojBoardView 200.0f

@interface InputBarControl ()<InputViewDelegate, EmojiViewDelegate>

/*!
 当前输入框状态
 */
@property(nonatomic) InputBarControlStatus currentBottomBarStatus;

/*!
 输入框
 */
@property(nonatomic, strong) InputView *inputBoxView;

/*!
 表情View
 */
@property(nonatomic, strong) EmojiBoardView *emojiBoardView;

@property(nonatomic, assign) CGRect originalFrame;
@end

@implementation InputBarControl

//  初始化
- (id)initWithStatus:(InputBarControlStatus)status {
    self = [super init];
    if (self) {
        [self setBackgroundColor:HEXCOLOR(0xfafafa)];
        [self initializedSubViews];
        [self registerNotification];
        [self setCurrentBottomBarStatus:status];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if(CGRectEqualToRect(self.originalFrame, CGRectZero)){
      self.originalFrame = frame;
    }
    [_inputBoxView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
}

-(void)setInputBarStatus:(InputBarControlStatus)Status {
    [self setCurrentBottomBarStatus:Status];
    //  弹出键盘
    if (Status == InputBarControlStatusKeyboard) {
        [_inputBoxView.emojiButton setSelected:NO];
        [_inputBoxView.inputTextView becomeFirstResponder];
    } else {
        if (Status == InputBarControlStatusEmoji) {
            [_inputBoxView.emojiButton setSelected:YES];
        } else {
            [_inputBoxView.emojiButton setSelected:NO];
        }
        //  其他状态隐藏键盘
        if (_inputBoxView.inputTextView.isFirstResponder) {
            [_inputBoxView.inputTextView resignFirstResponder];
        }
    }
    
    if (Status != InputBarControlStatusEmoji) {
        //  非emoji状态设置输入框InputView为nil
        [_inputBoxView.inputTextView setInputView:nil];
    }
}

-(void)changeInputBarFrame:(CGRect)frame{
    
}

#pragma mark - Notification action
- (void)keyboardWillShow:(NSNotification*)notification {
    CGRect keyboardBounds = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:0.2 animations:^{
        [UIView setAnimationCurve:curve];
        self.frame = CGRectMake(-([UIScreen mainScreen].bounds.size.width-self.originalFrame.size.width), self.originalFrame.origin.y-keyboardBounds.size.height,[UIScreen mainScreen].bounds.size.width,HeighInputBar);
        [UIView commitAnimations];
    }];
    if ([self.delegate respondsToSelector:@selector(onInputBarControlContentSizeChanged:withAnimationDuration:andAnimationCurve:)]) {
        [self.delegate onInputBarControlContentSizeChanged:self.frame withAnimationDuration:0.5 andAnimationCurve:curve];
    }
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [UIView animateWithDuration:0.2 animations:^{
        [UIView setAnimationCurve:0];
        self.frame = self.originalFrame;
        [UIView commitAnimations];
    }];
    if ([self.delegate respondsToSelector:@selector(onInputBarControlContentSizeChanged:withAnimationDuration:andAnimationCurve:)]) {
        [self.delegate onInputBarControlContentSizeChanged:self.originalFrame withAnimationDuration:0.1 andAnimationCurve:0];
    }
}

#pragma mark - RCCRInputViewDelegate
//  点击表情按钮
- (void)didTouchEmojiButton:(UIButton *)sender {
    if (!sender.selected) {
        [_inputBoxView.inputTextView setInputView:nil];
    } else {
        _inputBoxView.inputTextView.inputView = self.emojiBoardView;
    }
    [_inputBoxView.inputTextView reloadInputViews];
    [_inputBoxView.inputTextView becomeFirstResponder];
}

//  点击发送
- (void)didTouchKeyboardReturnKey:(InputView *)inputControl text:(NSString *)text {
    if([self.delegate respondsToSelector:@selector(onTouchSendButton:)]){
        [self.delegate onTouchSendButton:text];
    }
}

//  输入框内容变换
- (void)inputTextView:(UITextView *)inputTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([self.delegate respondsToSelector:@selector(onInputTextView:shouldChangeTextInRange:replacementText:)]){
        [self.delegate onInputTextView:inputTextView shouldChangeTextInRange:range replacementText:text];
    }
}

- (void)inputTextViewDidChange:(UITextView *)textView{
    BOOL sendDisable = self.inputBoxView.inputTextView.text.length > 0 ? NO : YES;
    [_emojiBoardView sendButtonDisable:sendDisable];
}
#pragma mark - RCCREmojiViewDelegate
//  发送表情
- (void)didSendButtonEvent {
    NSString *sendText = self.inputBoxView.inputTextView.text;
    NSString *formatString = [sendText
                               stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];    //去掉空格
    if (0 == [formatString length]) {
        return;
    }
    if([self.delegate respondsToSelector:@selector(onTouchSendButton:)]){
        [self.delegate onTouchSendButton:sendText];
    }
}

- (void)didTouchEmojiView:(EmojiBoardView *)emojiView touchedEmoji:(NSString *)string {
//    NSString *replaceString = string;
    if (string == nil) {
        [self.inputBoxView.inputTextView deleteBackward];
    } else {
        [self.inputBoxView.inputTextView setText:[self.inputBoxView.inputTextView.text stringByAppendingString:string]];
    }
    BOOL sendDisable = self.inputBoxView.inputTextView.text.length > 0 ? NO : YES;
    [_emojiBoardView sendButtonDisable:sendDisable];
}

#pragma mark - UI

- (void)initializedSubViews {
    [self addSubview:self.inputBoxView];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (InputView *)inputBoxView {
    if (!_inputBoxView) {
        _inputBoxView = [[InputView alloc] initWithStatus:InputBarControlStatusDefault];
        [_inputBoxView setDelegate:self];
    }
    return _inputBoxView;
}

//表情区域控件
- (EmojiBoardView *)emojiBoardView {
    if (!_emojiBoardView) {
        _emojiBoardView = [[EmojiBoardView alloc] initWithFrame:CGRectMake(0, 0,UIScreenWidth,HeightEmojBoardView)];
        _emojiBoardView.delegate = self;
        BOOL sendDisable = self.inputBoxView.inputTextView.text.length > 0 ? NO : YES;
        [_emojiBoardView sendButtonDisable:sendDisable];
    }
    return _emojiBoardView;
}

- (void)clearInputView {
    [self.inputBoxView clearInputText];
}

@end


