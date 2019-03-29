//
//  ApplySpeechMessage.m
//  SealClass
//
//  Created by Sin on 2019/3/14.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "ApplySpeechMessage.h"

@implementation ApplySpeechMessage
- (NSData *)encode {
    return nil;
}

- (void)decodeWithData:(NSData *)data {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if(dic) {
        self.requestUserId = dic[@"reqUserId"];
        self.requestUserName = dic[@"reqUserName"];
        self.ticket = dic[@"ticket"];
    }
}
+ (NSString *)getObjectName {
    return ApplySpeechMessageIdentifier;
}
- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}
- (NSString *)conversationDigest {
    return ApplySpeechMessageIdentifier;
}
@end
