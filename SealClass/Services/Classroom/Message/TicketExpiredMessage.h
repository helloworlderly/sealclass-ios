//
//  TicketExpiredMessage.h
//  SealClass
//
//  Created by LiFei on 2019/3/15.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN

#define TicketExpiredMessageIdentifier @"SC:TEMsg"

@interface TicketExpiredMessage : RCMessageContent
@property (nonatomic, copy) NSString *ticket;//请求凭证
@property (nonatomic, copy) NSString *fromUserId;//请求发言者
@property (nonatomic, copy) NSString *toUserId;//处理者
@end

NS_ASSUME_NONNULL_END
