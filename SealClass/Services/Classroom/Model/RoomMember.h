//
//  RoomMember.h
//  SealClass
//
//  Created by LiFei on 2019/2/28.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClassroomDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface RoomMember : NSObject

@property (nonatomic, copy)   NSString *userId;
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, assign) long long joinTime;
@property (nonatomic, assign) Role role;
@property (nonatomic, assign) BOOL cameraEnable;
@property (nonatomic, assign) BOOL microphoneEnable;

+ (instancetype)memberFromJson:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
