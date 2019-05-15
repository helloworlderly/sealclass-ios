//
//  SettingTableViewCell.h
//  SealClass
//
//  Created by 张改红 on 2019/3/4.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTCService.h"
NS_ASSUME_NONNULL_BEGIN

@protocol SettingResolutionCellDelegate <NSObject>
- (void)didSelectResolution:(RongRTCVideoSizePreset)perset;
@end
@interface SettingResolutionCell : UITableViewCell
+ (SettingResolutionCell *)configCell:(UITableView *)tableView;
@property (nonatomic, weak) id<SettingResolutionCellDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
