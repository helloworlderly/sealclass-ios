//
//  ZoomControl.h
//  SealClass
//
//  Created by 张改红 on 2019/4/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ZoomControlDelegate <NSObject>
- (void)zoomControlDelegate:(CGFloat)scale;
- (void)fullScreenDidUpdate:(BOOL)isFull;
@end
@interface ZoomControl : UIView
@property (nonatomic, weak) id<ZoomControlDelegate> delegate;
- (void)resetDefaultScale;
@end

NS_ASSUME_NONNULL_END
