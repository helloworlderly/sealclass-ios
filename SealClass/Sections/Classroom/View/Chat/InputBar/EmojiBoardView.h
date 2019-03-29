//
//  RCCREmojiBoardView.h
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/11.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EmojiBoardView;

/**
 表情输入的回调
 */
@protocol EmojiViewDelegate <NSObject>
@optional

/**
 点击表情的回调
 
 @param emojiView 表情输入的View
 @param string    点击的表情对应的字符串编码
 */
- (void)didTouchEmojiView:(EmojiBoardView *)emojiView touchedEmoji:(NSString *)string;

/**
 点击发送按钮的回调

 */
- (void)didSendButtonEvent;

@end

@interface EmojiBoardView : UIView

/*!
 表情输入的回调
 */
@property(nonatomic, weak) id<EmojiViewDelegate> delegate;

- (void)sendButtonDisable:(BOOL)disable;
@end
