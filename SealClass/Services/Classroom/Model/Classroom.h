//
//  Classroom.h
//  SealClass
//
//  Created by LiFei on 2019/2/28.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoomMember.h"
#import "Whiteboard.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DisplayType) {
    DisplayAssistant = 0,
    DisplayTeacher = 1,
    DisplayWhiteboard = 2,
    DisplaySharedScreen = 3,
    DisplayNone = 4
};

@interface Classroom : NSObject

@property (nonatomic, copy)   NSString *roomId;
@property (nonatomic, copy)   NSString *imToken;
@property (nonatomic, copy, readonly) NSString *currentMemberId;
@property (nonatomic, strong, readonly) RoomMember *currentMember;
@property (nonatomic, strong) NSArray<RoomMember *> *memberList;
@property (nonatomic, strong, readonly) RoomMember *teacher;
@property (nonatomic, strong, readonly) RoomMember *assistant;
@property (nonatomic, assign) DisplayType currentDisplayType;
@property (nonatomic, assign, readonly) long long joinTime;
//currentDisplayType 是 DisplayWhiteboard 时，currentDisplayURI 为白板 id；
//其它 type 时，currentDisplayURI 为对应的 userId
@property (nonatomic, copy)   NSString *currentDisplayURI;
//当前用户手动选择在共享画布区显示的视频用户 id
@property (nonatomic, copy) NSString *currentMaskUserId;

+ (instancetype)classroomFromJson:(NSDictionary *)dic;

- (BOOL)addMemeber:(RoomMember *)member;

- (BOOL)removeMemeber:(RoomMember *)member;

- (void)updateMemeber:(RoomMember *)member;

- (void)updateMemeber:(NSString *)userId forRole:(Role )role;

- (void)updateMember:(NSString *)userId forCamera:(BOOL)enable;

- (void)updateMember:(NSString *)userId forMicrophone:(BOOL)enable;

- (RoomMember *)getMember:(NSString *)userId;

- (void)updateDisplayUri:(NSString *)display;

- (int)getMemberCountWithoutAudience;
@end

NS_ASSUME_NONNULL_END
