//
//  ZoomControl.m
//  SealClass
//
//  Created by 张改红 on 2019/4/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "ZoomControl.h"
#import <Masonry.h>
@interface ZoomControl()
@property (nonatomic, strong) UIButton *reduceScaleBtn;
@property (nonatomic, strong) UIButton *increaseScaleBtn;
@property (nonatomic, strong) UIButton *fullScreenBtn;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, strong) NSArray *scaleList;
@end
@implementation ZoomControl
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubview];
        self.scaleList = @[@(1),@(2),@(3)];
        self.currentIndex = [self.scaleList indexOfObject:@(1)];
    }
    return self;
}

- (void)resetDefaultScale{
    self.currentIndex = [self.scaleList indexOfObject:@(1)];
    self.reduceScaleBtn.enabled = NO;
    self.increaseScaleBtn.enabled = YES;
}

#pragma mark - private
- (void)didReduceScaleAction{
    if (self.currentIndex > 0) {
        --self.currentIndex;
    }
    [self updateScaleEnable];
}

- (void)didIncreaseScaleAction{
    if (self.currentIndex < self.scaleList.count-1) {
        ++self.currentIndex;
    }
    [self updateScaleEnable];
}

- (void)fullScreenEvent{
    self.fullScreenBtn.selected = !self.fullScreenBtn.selected;
    if(self.delegate && [self.delegate respondsToSelector:@selector(fullScreenDidUpdate:)]){
        [self.delegate fullScreenDidUpdate:self.fullScreenBtn.selected];
    }
}

- (void)updateScaleEnable{
    if (self.currentIndex == 0) {
        self.reduceScaleBtn.enabled = NO;
    }else if (self.currentIndex == self.scaleList.count-1){
        self.increaseScaleBtn.enabled = NO;
    }else{
        self.reduceScaleBtn.enabled = YES;
        self.increaseScaleBtn.enabled = YES;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(zoomControlDelegate:)]){
        NSNumber *number = self.scaleList[self.currentIndex];
        [self.delegate zoomControlDelegate:[number floatValue]];
    }
}

- (void)setupSubview{
    [self addSubview:self.reduceScaleBtn];
    [self addSubview:self.increaseScaleBtn];
    [self addSubview:self.fullScreenBtn];
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).mas_offset(10);
        make.right.mas_equalTo(self).mas_offset(-10);
        make.width.height.mas_equalTo(18);
    }];
    
    [self.increaseScaleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fullScreenBtn.mas_top);
        make.right.equalTo(self.fullScreenBtn.mas_left).offset(-12);
        make.width.height.mas_equalTo(18);
    }];
    
    [self.reduceScaleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.increaseScaleBtn.mas_top);
        make.right.equalTo(self.increaseScaleBtn.mas_left).offset(-12);
        make.width.height.mas_equalTo(18);
    }];
}

#pragma mark - getter & setter
- (UIButton *)reduceScaleBtn{
    if (!_reduceScaleBtn) {
        _reduceScaleBtn = [[UIButton alloc] init];
        [_reduceScaleBtn setImage:[UIImage imageNamed:@"reduce"] forState:UIControlStateNormal];
        [_reduceScaleBtn setImage:[UIImage imageNamed:@"reduce_hover"] forState:UIControlStateHighlighted];
        [_reduceScaleBtn addTarget:self action:@selector(didReduceScaleAction) forControlEvents:UIControlEventTouchUpInside];
        _reduceScaleBtn.enabled = NO;
    }
    return _reduceScaleBtn;
}

- (UIButton *)increaseScaleBtn{
    if (!_increaseScaleBtn) {
        _increaseScaleBtn = [[UIButton alloc] init];
        [_increaseScaleBtn setImage:[UIImage imageNamed:@"increase"] forState:UIControlStateNormal];
        [_increaseScaleBtn setImage:[UIImage imageNamed:@"increase_hover"] forState:UIControlStateHighlighted];
        [_increaseScaleBtn addTarget:self action:@selector(didIncreaseScaleAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _increaseScaleBtn;
}

- (UIButton *)fullScreenBtn{
    if (!_fullScreenBtn) {
        _fullScreenBtn = [[UIButton alloc] init];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"fullScreen"] forState:UIControlStateNormal];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"quit_fullScreen"] forState:UIControlStateSelected];
        [_fullScreenBtn addTarget:self action:@selector(fullScreenEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenBtn;
}
@end
