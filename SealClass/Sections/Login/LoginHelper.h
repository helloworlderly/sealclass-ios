//
//  LoginHelper.h
//  SealClass
//
//  Created by 张改红 on 2019/3/12.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClassroomService.h"
#import <RongIMLib/RongIMLib.h>
#import "RTCService.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ClassroomHelperDelegate <NSObject>
@optional
- (void)classroomDidJoin:(Classroom *)classroom;
- (void)classroomDidJoinFail;
- (void)classroomDidOverMaxUserCount;
@end

//该类内部已经处理了各个模块中加入和离开的接口，加入房间、离开房间请调用该类中的方法
@interface LoginHelper : NSObject
+ (instancetype)sharedInstance;

@property (nonatomic, weak) id<ClassroomHelperDelegate> delegate;

- (void)login:(NSString *)roomId
         user:(NSString *)userName
   isAudience:(BOOL)audience;

- (void)logout:(void (^)(void))success
         error:(void (^)(RongRTCCode code))error;
@end

NS_ASSUME_NONNULL_END
