//
//  UpgradeDidApplyView.h
//  SealClass
//
//  Created by liyan on 2019/3/11.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomMember.h"

typedef enum : NSUInteger {
    UpgradeDidApplyViewAccept,
    UpgradeDidApplyViewRefuse,
} UpgradeDidApplyViewActionTag;

NS_ASSUME_NONNULL_BEGIN

@class UpgradeDidApplyView;
@protocol UpgradeDidApplyViewDelegate <NSObject>

- (void)upgradeDidApplyView:(UpgradeDidApplyView *)topView didTapAtTag:(UpgradeDidApplyViewActionTag)tag;

@end

@interface UpgradeDidApplyView : UIView

@property (nonatomic, weak) id<UpgradeDidApplyViewDelegate> delegate;

- (instancetype)initWithMember:(RoomMember *)member ticket:(NSString *)ticket;

@property (nonatomic, strong) RoomMember *member;

@property (nonatomic, strong) NSString *ticket;

@end

NS_ASSUME_NONNULL_END
