//
//  TicketExpiredMessage.h
//  SealClass
//
//  Created by LiFei on 2019/3/15.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "TicketExpiredMessage.h"

@implementation TicketExpiredMessage
- (NSData *)encode {
    return nil;
}

- (void)decodeWithData:(NSData *)data {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if(dic) {
        self.ticket = dic[@"ticket"];
        self.fromUserId = dic[@"fromUserId"];
        self.toUserId = dic[@"toUserId"];
    }
}

+ (NSString *)getObjectName {
    return TicketExpiredMessageIdentifier;
}

- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}

+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}

- (NSString *)conversationDigest {
    return TicketExpiredMessageIdentifier;
}
@end
