//
//  RCTimeStampMessage.m
//  RongIMKit
//
//  Created by zhaobingdong on 2018/10/12.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "TimeStampMessage.h"

@interface TimeStampMessage ()

@property(nonatomic, assign) NSTimeInterval timestamp;
@end

@implementation TimeStampMessage

- (instancetype)initWithTime:(NSTimeInterval)time {
    if (self = [super init]) {
        self.timestamp = time;
    }
    return self;
}

+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}

+ (NSString *)getObjectName {
    return TimeStampMessageIdentifier;
}
@end
