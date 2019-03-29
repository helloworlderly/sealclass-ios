//
//  ErrorCode.h
//  SealClass
//
//  Created by Sin on 2019/3/13.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#ifndef ErrorCode_h
#define ErrorCode_h


typedef NS_ENUM(NSInteger, ErrorCode) {
    ErrorCodeOther = 255,
    ErrorCodeSuccess = 0,
    ErrorCodeParameterError = 1,
    ErrorCodeInvalidAuth = 2,
    ErrorCodeAccessDenied = 3,
    ErrorCodeBadRequest = 4,
    ErrorCodeIMTokenError = 10,
    ErrorCodeCreateRoomError = 11,
    ErrorCodeJoinRoomError = 12,
    ErrorCodeRoomNotExist = 20,
    ErrorCodeUserNotExistInRoom = 21,
    ErrorCodeLeaveRoomError = 22,
    ErrorCodeTeacherNotExistInRoom = 23,
    ErrorCodeAssistantNotExistInRoom = 24,
    ErrorCodeCreateWhiteboardError = 25,
    ErrorCodeWhiteboardNotExist = 26,
    ErrorCodeDeleteWhiteboardError = 27,
    ErrorCodeUserExistInRoom = 28,
    ErrorCodeOverMaxUserCount = 31,
    ErrorCodeHTTPFailure = 99
};

#endif /* ErrorCode_h */
