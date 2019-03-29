//
//  ApplySpeechResultMessage.m
//  SealClass
//
//  Created by Sin on 2019/3/14.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "ApplySpeechResultMessage.h"

@implementation ApplySpeechResultMessage
- (NSData *)encode {
    return nil;
}

- (void)decodeWithData:(NSData *)data {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if(dic) {
        self.operatorId = dic[@"reqUserId"];
        self.operatorName = dic[@"reqUserName"];
        self.action = (SpeechResultAction)[dic[@"action"] integerValue];
    }
}
+ (NSString *)getObjectName {
    return SpeechResultMessageIdentifier;
}
- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}
- (NSString *)conversationDigest {
    return SpeechResultMessageIdentifier;
}
@end
