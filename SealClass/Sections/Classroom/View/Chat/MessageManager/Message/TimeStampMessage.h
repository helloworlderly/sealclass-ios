//
//  RCTimeStampMessage.h
//  RongIMKit
//
//  Created by zhaobingdong on 2018/10/12.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
#define TimeStampMessageIdentifier @"SC:TMSMsg"

@interface TimeStampMessage : RCMessageContent

- (instancetype)initWithTime:(NSTimeInterval)time;

@property (nonatomic, assign, readonly) NSTimeInterval timestamp;

@property (nonatomic, copy) NSString *timeText;
@end
