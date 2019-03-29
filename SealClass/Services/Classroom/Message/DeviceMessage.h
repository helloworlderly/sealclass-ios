//
//  DeviceMessage.h
//  SealClass
//
//  Created by Sin on 2019/3/12.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
#import "ClassroomDefine.h"

#define DeviceMessageIdentifier @"SC:DRMsg"

/**
 RTC room 设备消息，由服务下发，通知端上硬件的行为，如麦克风、相机等是否可用
 @note 该消息只能由服务下发
 */
@interface DeviceMessage : RCMessageContent
@property (nonatomic, copy)   NSString *userId;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, assign) DeviceType type;
@end

