//
//  EmptyView.h
//  SealClass
//
//  Created by Zhaoqianyu on 2019/3/13.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomMember.h"

NS_ASSUME_NONNULL_BEGIN

@interface EmptyView : UIView
- (instancetype)initWithFrame:(CGRect)frame role:(Role)role;

/**
 切换角色

 @param role 当前角色
 @discussion 不同角色显示不同
 */
- (void)changeRole:(Role)role;
@end

NS_ASSUME_NONNULL_END
