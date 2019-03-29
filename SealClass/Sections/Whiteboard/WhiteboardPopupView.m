//
//  WhiteboardPopupView.m
//  SealClass
//
//  Created by Zhaoqianyu on 2019/3/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "WhiteboardPopupView.h"
#import <Masonry/Masonry.h>

#define ShapeWidth 7

@interface WhiteboardPopupView()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) NSArray<NSString *> *items;
@property(nonatomic, strong) UITableView *itemListView;
@property(nonatomic, assign) CGFloat shapePointY;
@property(nonatomic, copy) SelectItemBlock selectItemBlock;
@property(nonatomic, strong) UIView *backGroundView;

@end

@implementation WhiteboardPopupView

- (instancetype)initWithFrame:(CGRect)frame
                  shapePointY:(CGFloat)shapePointY
                        items:(NSArray<NSString *> *)items
                didSelectItem:(SelectItemBlock)didSelectItem{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.items = items;
        self.shapePointY = shapePointY;
        self.selectItemBlock = didSelectItem;
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow addSubview:self.backGroundView];
        [self.backGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(keyWindow);
        }];
        [self addSubview:self.itemListView];
        [self.itemListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.mas_equalTo(self);
            make.left.mas_equalTo(self).mas_offset(ShapeWidth);
        }];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGFloat whidth = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat startX = ShapeWidth;
    CGFloat startY = 0;
    CGFloat shapeOriginY = self.shapePointY;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, startX, startY);
    CGContextAddLineToPoint(context, startX, startY+shapeOriginY-ShapeWidth);
    CGContextAddLineToPoint(context, startX-ShapeWidth, startY+shapeOriginY);
    CGContextAddLineToPoint(context, startX, startY+shapeOriginY+ShapeWidth);
    CGContextAddLineToPoint(context, startX, startY+height);
    CGContextAddLineToPoint(context, whidth, startY+height);
    CGContextAddLineToPoint(context, whidth, 0);
    CGContextAddLineToPoint(context, startX, startY);
    CGContextClosePath(context);
    [[UIColor blackColor] setFill];
    CGContextDrawPath(context, kCGPathFillStroke);

}

- (void)destroy {
    [self.backGroundView removeFromSuperview];
    [self removeFromSuperview];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.bounds.size.height/self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"WhiteboardPopupView-cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    [cell.textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(cell.contentView);
    }];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = self.items[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *item = self.items[indexPath.row];
    if (self.selectItemBlock) {
        self.selectItemBlock(indexPath.row, item);
    }
    [self.backGroundView removeFromSuperview];
    [self removeFromSuperview];
}

#pragma mark - Getters

- (UITableView *)itemListView {
    if (!_itemListView) {
        _itemListView = [[UITableView alloc] initWithFrame:self.bounds];
        _itemListView.backgroundColor = [UIColor clearColor];
        _itemListView.delegate = self;
        _itemListView.dataSource = self;
        _itemListView.showsHorizontalScrollIndicator = NO;
        _itemListView.showsVerticalScrollIndicator = NO;
        _itemListView.scrollEnabled = NO;
        _itemListView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _itemListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _itemListView;
}

- (UIView *)backGroundView {
    if (!_backGroundView) {
        _backGroundView = [[UIView alloc] init];
        _backGroundView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(destroy)];
        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(destroy)];
        [_backGroundView addGestureRecognizer:tapGes];
        [_backGroundView addGestureRecognizer:panGes];
    }
    return _backGroundView;
}

@end
