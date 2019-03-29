//
//  PersonListView.h
//  SealClass
//
//  Created by Sin on 2019/2/28.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomMember.h"

typedef enum : NSUInteger {
    RefreshPersonListTagRemove,//删除人员
    RefreshPersonListTagRefresh,//刷新人员
} RefreshPersonListTag;

NS_ASSUME_NONNULL_BEGIN

@interface PersonListView : UIView

@property (nonatomic, assign) BOOL curMemberApplying;

- (void)reloadPersonList;

- (void)reloadPersonList:(RoomMember *)member tag:(RefreshPersonListTag)tag;

@end

NS_ASSUME_NONNULL_END
