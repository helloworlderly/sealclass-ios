//
//  RoleChangedMessage.m
//  SealClass
//
//  Created by Sin on 2019/3/14.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "RoleChangedMessage.h"

@implementation RoleChangedMessage
- (NSData *)encode {
    return nil;
}

- (void)decodeWithData:(NSData *)data {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if(dic) {
        self.operatorId = dic[@"opUserId"];
        self.users = dic[@"users"];
    }
}
+ (NSString *)getObjectName {
    return RoleChangedMessageIdentifier;
}
- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}
- (NSString *)conversationDigest {
    return RoleChangedMessageIdentifier;
}
@end
