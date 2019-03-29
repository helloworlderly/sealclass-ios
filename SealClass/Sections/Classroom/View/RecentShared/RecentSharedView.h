//
//  RecentSharedView.h
//  SealClass
//
//  Created by liyan on 2019/3/6.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Whiteboard.h"

NS_ASSUME_NONNULL_BEGIN

@class RecentSharedView;
@protocol RecentSharedViewDelegate <NSObject>

- (void)recentSharedViewCellTap:(id)recentShared;

@end

@interface RecentSharedView : UIView

@property (nonatomic, weak) id<RecentSharedViewDelegate> delegate;

- (void)reloadDataSource;

@end

NS_ASSUME_NONNULL_END
