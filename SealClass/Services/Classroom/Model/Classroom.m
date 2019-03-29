//
//  Classroom.m
//  SealClass
//
//  Created by LiFei on 2019/2/28.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "Classroom.h"

@interface Classroom ()
@property (nonatomic, copy) NSString *currentMemberId;
@property (nonatomic, assign) long long joinTime;
@end

@implementation Classroom

+ (instancetype)classroomFromJson:(NSDictionary *)dic {
    Classroom *room = [[Classroom alloc] init];
    room.roomId = dic[@"roomId"];
    room.imToken = dic[@"imToken"];
    NSString *display = dic[@"display"];
    
    [room updateDisplayUri:display];
    NSArray *memberArray = dic[@"members"];
    NSMutableArray *memberList = [[NSMutableArray alloc] init];
    for (NSDictionary *memberDic in memberArray) {
        RoomMember *member = [RoomMember memberFromJson:memberDic];
        [memberList addObject:member];
    }
    room.memberList = memberList;
    NSDictionary *userDic = dic[@"userInfo"];
    RoomMember *currentMember = [RoomMember memberFromJson:userDic];
    room.currentMemberId = currentMember.userId;
    room.joinTime = currentMember.joinTime;
    
    return room;
}
- (BOOL)addMemeber:(RoomMember *)member {
    BOOL canAdd = [self indexInDataSource:member] < 0 ? YES:NO;
    
    if(canAdd) {
        NSMutableArray *tmp = [self.memberList mutableCopy];
        [tmp addObject:member];
        self.memberList = [tmp copy];
    }
    return canAdd;
}

- (BOOL)removeMemeber:(RoomMember *)member {
    int index = [self indexInDataSource:member];
    BOOL canRemove = index >= 0 ? YES:NO ;
    if(canRemove) {
        NSMutableArray *tmp = [self.memberList mutableCopy];
        [tmp removeObjectAtIndex:index];
        self.memberList = [tmp copy];
    }
    return canRemove;
}

- (void)updateMemeber:(NSString *)userId forRole:(Role )role {
    RoomMember *memeber = [self getMember:userId];
    memeber.role = role;
    [self updateMemeber:memeber];
}

- (void)updateMember:(NSString *)userId forCamera:(BOOL)enable {
    RoomMember *member = [self getMember:userId];
    member.cameraEnable = enable;
    [self updateMemeber:member];
}

- (void)updateMember:(NSString *)userId forMicrophone:(BOOL)enable {
    RoomMember *member = [self getMember:userId];
    member.microphoneEnable = enable;
    [self updateMemeber:member];
}

- (void)updateMemeber:(RoomMember *)member {
    int index = [self indexInDataSource:member];
    if(index >= 0) {
        NSMutableArray *tmp = [self.memberList mutableCopy];
        [tmp replaceObjectAtIndex:index withObject:member];
        self.memberList = [tmp copy];
    }
}

- (RoomMember *)getMember:(NSString *)userId {
    for(RoomMember *mem in self.memberList) {
        if([mem.userId isEqualToString:userId]) {
            return mem;
        }
    }
    return nil;
}

- (void)updateDisplayUri:(NSString *)display {
    if(display.length == 0){
        self.currentDisplayType = DisplayNone;
        self.currentDisplayURI = @"";
        return;
    }
    NSRange typeRange = [display rangeOfString:@"display://type="];
    NSRange userIdRange = [display rangeOfString:@"?userId="];
    NSRange uriRange = [display rangeOfString:@"?uri="];
    DisplayType type = (DisplayType)[[display substringWithRange:NSMakeRange(NSMaxRange(typeRange), 1)] intValue];
    NSString *userId = nil;
    NSInteger location = uriRange.location;
    if(display.length < location) {
        location = display.length;
    }
    if(userIdRange.location != NSNotFound) {
        userId = [display substringWithRange:NSMakeRange(NSMaxRange(userIdRange), location-NSMaxRange(userIdRange))];
    }
    NSString *uri = nil;
    if(uriRange.location != NSNotFound) {
        uri =[display substringWithRange:NSMakeRange(NSMaxRange(uriRange), display.length-NSMaxRange(uriRange))];
    }
    self.currentDisplayType = type;
    if(type == DisplayAssistant || type == DisplayTeacher || type == DisplaySharedScreen) {
        self.currentDisplayURI = userId;
    }else if (type == DisplayWhiteboard) {
        self.currentDisplayURI = uri;
    }
}

- (int)indexInDataSource:(RoomMember *)member {
    int index = -1;
    for(int i=0;i<self.memberList.count;i++) {
        RoomMember *mem = self.memberList[i];
        if([mem.userId isEqualToString:member.userId]) {
            index = i;
            break;
        }
    }
    return index;
}

- (RoomMember *)teacher {
    for(RoomMember *mem in self.memberList) {
        if(mem.role == RoleTeacher) {
            return mem;
        }
    }
    return nil;
}

- (RoomMember *)assistant {
    for(RoomMember *mem in self.memberList) {
        if(mem.role == RoleAssistant) {
            return mem;
        }
    }
    return nil;
}

- (RoomMember *)currentMember {
    return [self getMember:self.currentMemberId];
}

- (int)getMemberCountWithoutAudience {
    int count = 0;
    for (RoomMember *mem in self.memberList) {
        if (mem.role != RoleAudience) {
            count ++;
        }
    }
    return count;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Classroom:%@ displayType:%@ displayUri:%@ memeberList:%@", self.roomId,@(self.currentDisplayType),self.currentDisplayURI,self.memberList];
}
@end
