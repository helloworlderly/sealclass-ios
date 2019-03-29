//
//  WhiteboardMessage.m
//  SealClass
//
//  Created by Sin on 2019/3/12.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "WhiteboardMessage.h"

@implementation WhiteboardMessage
- (NSData *)encode {
    return nil;
}

- (void)decodeWithData:(NSData *)data {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if(dic) {
        self.whiteboardId = dic[@"whiteboardId"];
        self.whiteboardName = dic[@"whiteboardName"];
        self.action = (WhiteboardAction)[dic[@"action"] intValue];
    }
}
+ (NSString *)getObjectName {
    return WhiteboardMessageIdentifier;
}
- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}
- (NSString *)conversationDigest {
    return WhiteboardMessageIdentifier;
}
@end
