//
//  SettingTableViewCell.h
//  SealClass
//
//  Created by 张改红 on 2019/3/4.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface SettingTableViewCell : UITableViewCell
+ (SettingTableViewCell *)configCell:(UITableView *)tableView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;
@end

NS_ASSUME_NONNULL_END
