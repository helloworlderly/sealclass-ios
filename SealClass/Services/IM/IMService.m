//
//  IMService.m
//  SealClass
//
//  Created by LiFei on 2019/3/15.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "IMService.h"
#import "ClassroomService.h"

@implementation IMService

+ (instancetype)sharedService {
    static IMService *service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[IMService alloc] init];
        [[ClassroomService sharedService] registerCommandMessages];
    });
    return service;
}

- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object {
    if (![[ClassroomService sharedService] isHoldMessage:message]) {
        if ([self.receiveMessageDelegate respondsToSelector:@selector(onReceiveMessage:left:object:)]) {
            [self.receiveMessageDelegate onReceiveMessage:message left:nLeft object:object];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:OnReceiveMessageNotification object:@{@"message":message,@"left":@(nLeft)}];
    }
}

@end
