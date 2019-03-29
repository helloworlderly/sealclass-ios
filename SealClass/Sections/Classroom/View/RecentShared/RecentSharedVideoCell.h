//
//  RecentSharedVideoCell.h
//  SealClass
//
//  Created by liyan on 2019/3/13.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomMember.h"

NS_ASSUME_NONNULL_BEGIN

@interface RecentSharedVideoCell : UITableViewCell

- (void)setModel:(RoomMember *)member;

@end

NS_ASSUME_NONNULL_END
