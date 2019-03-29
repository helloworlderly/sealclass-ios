//
//  RoomMember.m
//  SealClass
//
//  Created by LiFei on 2019/2/28.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RoomMember.h"

@implementation RoomMember

+ (instancetype)memberFromJson:(NSDictionary *)dic {
    RoomMember *member = [[RoomMember alloc] init];
    member.userId = dic[@"userId"];
    member.name = dic[@"userName"];
    member.joinTime = [dic[@"joinTime"] longLongValue];
    member.role = [dic[@"role"] longValue];
    member.cameraEnable = [dic[@"camera"] boolValue];
    member.microphoneEnable = [dic[@"microphone"] boolValue];
    
    return member;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"RoomMember:%@ name:%@ joinTime:%@ cameraEnable:%@ microphoneEnable:%@", self.userId,self.name,@(self.joinTime),@(self.cameraEnable),@(self.microphoneEnable)];
}
@end
