//
//  ChatAreaView.h
//  SealClass
//
//  Created by Sin on 2019/2/28.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMLib/RongIMLib.h>
#import "InputBarControl.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatAreaView : UIView

@property (nonatomic, strong) InputBarControl *inputBarControl;

- (instancetype)initWithFrame:(CGRect)frame conversationType:(RCConversationType)conversationType targetId:(NSString *)targetId;

@end

NS_ASSUME_NONNULL_END
