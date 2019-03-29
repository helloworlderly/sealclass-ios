//
//  ClassroomDefine.h
//  SealClass
//
//  Created by LiFei on 2019/3/19.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#ifndef ClassroomDefine_h
#define ClassroomDefine_h

typedef NS_ENUM(NSUInteger, Role) {
    //助教
    RoleAssistant = 1,
    //老师
    RoleTeacher = 2,
    //学生
    RoleStudent = 3,
    //旁观者
    RoleAudience = 4,
};

typedef NS_ENUM(NSUInteger, DeviceType) {
    //麦克风
    DeviceTypeMicrophone = 0,
    //相机
    DeviceTypeCamera = 1,
};

#endif /* ClassroomDefine_h */
