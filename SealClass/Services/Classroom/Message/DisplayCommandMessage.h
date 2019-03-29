//
//  DisplayCommandMessage.h
//  SealClass
//
//  Created by Sin on 2019/3/12.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

#define DisplayCommandMessageIdentifier @"SC:DisplayMsg"
@interface DisplayCommandMessage : RCMessageContent
@property (nonatomic, copy) NSString *display;
@end


