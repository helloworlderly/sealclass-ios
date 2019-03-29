//
//  MemberChangeMessage.m
//  SealClass
//
//  Created by Sin on 2019/3/12.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "MemberChangeMessage.h"

@implementation MemberChangeMessage
- (NSData *)encode {
    return nil;
}

- (void)decodeWithData:(NSData *)data {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if(dic) {
        self.userId = dic[@"userId"];
        self.userName = dic[@"userName"];
        self.role = [dic[@"role"] intValue];
        self.action = [dic[@"action"] integerValue];
        self.timestamp = [dic[@"timestamp"] longValue];
    }
}
+ (NSString *)getObjectName {
    return MemberChangeMessageIdentifier;
}
- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}

+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_ISPERSISTED;
}
@end
