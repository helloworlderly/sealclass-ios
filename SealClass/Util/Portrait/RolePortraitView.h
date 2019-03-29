//
//  RolePortraitView.h
//  SealClass
//
//  Created by 张改红 on 2019/3/15.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RoomMember;

NS_ASSUME_NONNULL_BEGIN

@interface RolePortraitView : UIView
- (void)addHeaderBackground:(RoomMember *)member;
@end

NS_ASSUME_NONNULL_END
