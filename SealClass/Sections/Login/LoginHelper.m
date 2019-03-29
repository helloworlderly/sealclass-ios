//
//  LoginHelper.m
//  SealClass
//
//  Created by 张改红 on 2019/3/12.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "LoginHelper.h"
@interface LoginHelper()<RongRTCRoomDelegate, RCConnectionStatusChangeDelegate>
@property (nonatomic, strong) Classroom *classroom;
@end

@implementation LoginHelper
+ (instancetype)sharedInstance {
    static LoginHelper *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[self alloc] init];
        [IMClient setRCConnectionStatusChangeDelegate:service];
    });
    return service;
}

#pragma mark - Api
- (void)login:(NSString *)roomId user:(NSString *)userName isAudience:(BOOL)audience{
    NSLog(@"login start");
    [[ClassroomService sharedService] joinClassroom:roomId userName:userName isAudience:audience success:^(Classroom * _Nonnull classroom) {
        NSLog(@"login classroom success");
        self.classroom = classroom;
        __weak typeof(self) weakSelf = self;
        NSLog(@"connect im start");
        [IMClient connectWithToken:classroom.imToken success:^(NSString *userId) {
        } error:^(RCConnectErrorCode status) {
            NSLog(@"connect im error:%@",@(status));
            if (status != RC_CONN_REDIRECTED) {
                dispatch_main_async_safe(^{
                    NSLog(@"IM connect error");
                    if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(classroomDidJoinFail)]){
                        [weakSelf.delegate classroomDidJoinFail];
                    }
                });
            }
        } tokenIncorrect:^{
            NSLog(@"connect im token incorrect");
            dispatch_main_async_safe(^{
                if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(classroomDidJoinFail)]){
                    [weakSelf.delegate classroomDidJoinFail];
                }
            });
        }];
        [[RCIMClient sharedRCIMClient] clearConversations:@[@(ConversationType_GROUP)]];
    } error:^(ErrorCode errorCode){
        NSLog(@"login classroom error:%@",@(errorCode));
            if (errorCode == ErrorCodeOverMaxUserCount) {
                if(self.delegate && [self.delegate respondsToSelector:@selector(classroomDidOverMaxUserCount)]){
                    [self.delegate classroomDidOverMaxUserCount];
                }
            }else{
                if(self.delegate && [self.delegate respondsToSelector:@selector(classroomDidJoinFail)]){
                    [self.delegate classroomDidJoinFail];
                }
            }
    }];
}

- (void)logout:(void (^)(void))success error:(void (^)(RongRTCCode code))error {
    NSLog(@"logout start");
    [[RTCService sharedInstance] leaveRongRTCRoom:[ClassroomService sharedService].currentRoom.roomId success:^{
        NSLog(@"leave rtc room success");
        dispatch_main_async_safe(^{
            if (success) {
                success();
            }
             [self leaveRoom];
        });
    } error:^(RongRTCCode code) {//todo
        NSLog(@"leave rtc room error:%@",@(code));
        dispatch_main_async_safe(^{
            if (error) {
                error(code);
            }
        });
    }];
}

- (void)leaveRoom {
    [[ClassroomService sharedService] leaveClassroom];
    [[RCIMClient sharedRCIMClient] disconnect];
}

#pragma mark - RCConnectionStatusChangeDelegate
- (void)onConnectionStatusChanged:(RCConnectionStatus)status{
    if (status == ConnectionStatus_Connected) {
        NSLog(@"connect im success");
        [self joinRongRTCRoom];
    }
}

#pragma mark - Helper
- (void)joinRongRTCRoom{
    NSLog(@"join rtc room start");
    [[RTCService sharedInstance] joinRongRTCRoom:self.classroom.roomId success:^(RongRTCRoom * _Nonnull room) {
        NSLog(@"join rtc room success");
        dispatch_main_async_safe(^{
            if(self.delegate && [self.delegate respondsToSelector:@selector(classroomDidJoin:)]){
                [self.delegate classroomDidJoin:self.classroom];
            }
        });
    } error:^(RongRTCCode code) {
        NSLog(@"join rtc room error:%@",@(code));
        dispatch_main_async_safe(^{
            if (code == RongRTCCodeJoinRepeatedRoom || code == RongRTCCodeJoinToSameRoom) {
                if(self.delegate && [self.delegate respondsToSelector:@selector(classroomDidJoin:)]){
                    [self.delegate classroomDidJoin:self.classroom];
                }
            }else{
                if(self.delegate && [self.delegate respondsToSelector:@selector(classroomDidJoinFail)]){
                    [self.delegate classroomDidJoinFail];
                }
            }
        });
    }];
}
@end
