//
//  InviteUpgradeMessage.m
//  SealClass
//
//  Created by LiFei on 2019/3/19.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "InviteUpgradeMessage.h"

@implementation InviteUpgradeMessage
- (NSData *)encode {
    return nil;
}

- (void)decodeWithData:(NSData *)data {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if(dic) {
        self.action = [dic[@"action"] longValue];
        self.role = [dic[@"role"] longValue];
        self.operatorId = dic[@"opUserId"];
        self.operatorName = dic[@"opUserName"];
        self.ticket = dic[@"ticket"];
    }
}

+ (NSString *)getObjectName {
    return InviteUpgradeMessageIdentifier;
}

- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}

+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}

- (NSString *)conversationDigest {
    return InviteUpgradeMessageIdentifier;
}
@end
