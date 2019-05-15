//
//  VideoMaskView.m
//  SealClass
//
//  Created by Sin on 2019/4/25.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "VideoMaskView.h"
#import <Masonry.h>

@interface VideoMaskView ()
@property (nonatomic, strong) UIButton *dismissBtn;
@property (nonatomic, strong) UIView *backView;
@end

@implementation VideoMaskView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    self.backgroundColor = [UIColor colorWithHexString:@"131B23" alpha:0.9];
    
    [self addSubview:self.backView];
    [self.backView addSubview:self.maskVideoView];
    [self.backView addSubview:self.dismissBtn];
    
    [self.dismissBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.backView);
        make.right.mas_equalTo(self.backView);
        make.width.height.mas_equalTo(27);
    }];
}

- (void)addDismisTarget:(id)target action:(SEL)act{
    [self.dismissBtn addTarget:target action:act forControlEvents:UIControlEventTouchUpInside];
}
- (void)cancelRenderView {
    for(UIView *v in self.maskVideoView.subviews) {
        [v removeFromSuperview];
    }
}

#pragma mark - getter
- (UIView *)maskVideoView {
    if(!_maskVideoView) {
        CGFloat topMargin = 10;
        CGFloat leftMargin = 10;
        CGRect frame = self.backView.bounds;
        frame.origin.x += leftMargin;
        frame.origin.y += topMargin;
        frame.size.width -= leftMargin * 2;
        frame.size.height -= topMargin * 2;
        _maskVideoView = [[UIView alloc] initWithFrame:frame];
        _maskVideoView.backgroundColor = [UIColor colorWithHexString:@"3D4041" alpha:1];
    }
    return _maskVideoView;
}

- (UIView *)backView {
    if(!_backView) {
        CGFloat topMargin = 13;
        CGFloat leftMargin = 10.5;
        CGRect frame = self.bounds;
        frame.origin.x += leftMargin;
        frame.origin.y += topMargin;
        frame.size.width -= leftMargin * 2;
        frame.size.height -= topMargin * 2;
        _backView = [[UIView alloc] initWithFrame:frame];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.layer.masksToBounds = YES;
        _backView.layer.cornerRadius = 10;
    }
    return _backView;
}
- (UIButton *)dismissBtn {
    if(!_dismissBtn) {
        _dismissBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_dismissBtn setImage:[UIImage imageNamed:@"vedio_delete"] forState:UIControlStateNormal];
    }
    return _dismissBtn;
}

@end
