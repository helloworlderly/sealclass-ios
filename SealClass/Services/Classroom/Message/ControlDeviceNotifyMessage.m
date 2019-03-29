//
//  ControlDeviceNotifyMessage.m
//  SealClass
//
//  Created by LiFei on 2019/3/19.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "ControlDeviceNotifyMessage.h"

@implementation ControlDeviceNotifyMessage
- (NSData *)encode {
    return nil;
}

- (void)decodeWithData:(NSData *)data {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if(dic) {
        self.action = [dic[@"action"] longValue];
        self.type = [dic[@"type"] longValue];
        self.opUserId = dic[@"opUserId"];
        self.opUserName = dic[@"opUserName"];
        self.ticket = dic[@"ticket"];
    }
}

+ (NSString *)getObjectName {
    return ControlDeviceNotifyMessageIdentifier;
}

- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}

+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}

- (NSString *)conversationDigest {
    return ControlDeviceNotifyMessageIdentifier;
}
@end
