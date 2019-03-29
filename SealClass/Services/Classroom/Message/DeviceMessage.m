//
//  DeviceMessage.m
//  SealClass
//
//  Created by Sin on 2019/3/12.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "DeviceMessage.h"

@implementation DeviceMessage
- (NSData *)encode {
    return nil;
}

- (void)decodeWithData:(NSData *)data {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if(dic) {
        self.enable = [dic[@"enable"] boolValue];
        self.type = (DeviceType)[dic[@"type"] integerValue];
        self.userId = dic[@"userId"];
    }
}
+ (NSString *)getObjectName {
    return DeviceMessageIdentifier;
}
- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}
- (NSString *)conversationDigest {
    return DeviceMessageIdentifier;
}
@end
