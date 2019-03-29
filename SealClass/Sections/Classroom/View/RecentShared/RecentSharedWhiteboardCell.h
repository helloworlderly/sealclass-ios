//
//  RecentSharedWhiteboardCell.h
//  SealClass
//
//  Created by liyan on 2019/3/6.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Whiteboard.h"

NS_ASSUME_NONNULL_BEGIN

@interface RecentSharedWhiteboardCell : UITableViewCell

- (void)setModel:(Whiteboard *)whiteboard;

@end

NS_ASSUME_NONNULL_END
