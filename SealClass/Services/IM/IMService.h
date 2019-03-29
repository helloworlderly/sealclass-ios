//
//  IMService.h
//  SealClass
//
//  Created by LiFei on 2019/3/15.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN

@protocol IMReceiveMessageDelegate <NSObject>

- (void)onReceiveMessage:(RCMessage *)message left:(int)nLeft object:(id)object;

@end

@interface IMService : NSObject <RCIMClientReceiveMessageDelegate>

@property (nonatomic, weak) id<IMReceiveMessageDelegate> receiveMessageDelegate;

+ (instancetype)sharedService;

@end


NS_ASSUME_NONNULL_END
