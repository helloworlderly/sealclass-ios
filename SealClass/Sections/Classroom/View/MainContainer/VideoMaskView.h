//
//  VideoMaskView.h
//  SealClass
//
//  Created by Sin on 2019/4/25.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoMaskView : UIView
- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic, strong) UIView *maskVideoView;
- (void)addDismisTarget:(id)target action:(SEL)act;
- (void)cancelRenderView;
@end

NS_ASSUME_NONNULL_END
