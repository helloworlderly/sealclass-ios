//
//  TurnPageMessage.m
//  SealClass
//
//  Created by Sin on 2019/3/15.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "TurnPageMessage.h"

@implementation TurnPageMessage
- (NSData *)encode {
    return nil;
}

- (void)decodeWithData:(NSData *)data {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if(dic) {
        self.whiteboardId = dic[@"whiteboardId"];
        self.userId = dic[@"userId"];
        self.currentPage = [dic[@"curPg"] intValue];
    }
}
+ (NSString *)getObjectName {
    return TurnPageMessageIdentifier;
}
- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}
- (NSString *)conversationDigest {
    return TurnPageMessageIdentifier;
}
@end
