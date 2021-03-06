//
//  ChatAreaView.m
//  SealClass
//
//  Created by Sin on 2019/2/28.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "ChatAreaView.h"
#import <RongIMLib/RongIMLib.h>
#import "MessageDataSource.h"
#import "MessageBaseCell.h"
#import "MessageCell.h"
#import "MJRefresh.h"
#import "MessageHelper.h"
#import "TimeStampMessage.h"
#import "TextMessageCell.h"
#import "TimeStampCell.h"
#import "TipMessageCell.h"
#import "MemberChangeMessage.h"
#define unknownMessageIdentifier @"unknownMessageIdentifier"
@interface ChatAreaView()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, InputBarControlDelegate, MessageDataSourceDelegate>

@property (nonatomic, assign) RCConversationType conversationType;
@property (nonatomic, copy)   NSString *targetId;
@property (nonatomic, strong) UITableView *messageListView;
@property (nonatomic, strong) MessageDataSource *dataSource;
@property (nonatomic, assign) BOOL isLoadingHistoryMessage; ///是否正在加载历史消息
@end
@implementation ChatAreaView
- (instancetype)initWithFrame:(CGRect)frame conversationType:(RCConversationType)conversationType targetId:(NSString *)targetId{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = HEXCOLOR(0xe1e4e5);
        [self addSubview:self.messageListView];
        [self addSubview:self.inputBarControl];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:self action:@selector(didTap)];
        [self addGestureRecognizer:tap];
        [[MessageHelper sharedInstance] setMaximumContentWidth:frame.size.width];
        self.dataSource = [[MessageDataSource alloc] initWithTargetId:targetId conversationType:conversationType];
        self.dataSource.delegate = self;
        self.conversationType = conversationType;
        self.targetId = targetId;
        [self registerCell];
    }
    return self;
}

#pragma mark - MessageDataSourceDelegate
- (void)lastestMessageLoadCompleted{
    [self scrollToBottomWithAnimated:NO];
}

- (void)didInsert:(MessageModel *)model startIndex:(NSInteger)index{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(long)index inSection:0];
    [self.messageListView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
    [self scrollToBottomWithAnimated:YES];
}

- (void)didSendStatusUpdate:(MessageModel *)model index:(NSInteger)index{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    MessageBaseCell *cell = [self.messageListView cellForRowAtIndexPath:indexPath];
    if (cell && [cell isKindOfClass:MessageCell.class]) {
        MessageCell *itemCell = (MessageCell*)cell;
        [itemCell updateSentStatus];
    }
}

- (void)didLoadHistory:(NSArray<MessageModel *> *)models isRemaining:(BOOL)remain{
    if (models.count == 0) {
        self.isLoadingHistoryMessage = NO;
        [self.messageListView.mj_header endRefreshing];
        return;
    }
    NSMutableArray *indexPathes = [[NSMutableArray alloc] initWithCapacity:20];
    CGFloat height = self.messageListView.contentSize.height;
    for (int i = 0; i < models.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        MessageModel *msgModel = [self.dataSource objectAtIndex:i];
        height += [msgModel contentSize].height;
        [indexPathes addObject:indexPath];
    }
    if (indexPathes.count <= 0) {
        self.isLoadingHistoryMessage = NO;
        [self.messageListView.mj_header endRefreshing];
        return;
    }
    self.isLoadingHistoryMessage = NO;
    [self.messageListView.mj_header endRefreshing];
    if (@available(iOS 11.0, *)) {
        [UIView setAnimationsEnabled:NO];
        [self.messageListView performBatchUpdates:^{
            [self.messageListView insertRowsAtIndexPaths:indexPathes withRowAnimation:(UITableViewRowAnimationNone)];
        } completion:^(BOOL finished) {
            [self.messageListView scrollToRowAtIndexPath:indexPathes.lastObject atScrollPosition:UITableViewScrollPositionTop animated:NO];
             [UIView setAnimationsEnabled:YES];
        }];
    } else {
        [UIView setAnimationsEnabled:NO];
        [self.messageListView insertRowsAtIndexPaths:indexPathes withRowAnimation:(UITableViewRowAnimationNone)];
        [self.messageListView scrollToRowAtIndexPath:indexPathes.lastObject atScrollPosition:UITableViewScrollPositionTop animated:NO];
        [UIView setAnimationsEnabled:YES];
    }
    
}

- (void)didRemoved:(MessageModel *)model atIndex:(NSInteger)index{
    [UIView setAnimationsEnabled:NO];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.messageListView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
    [UIView setAnimationsEnabled:YES];
}

- (void)forceReloadData{
    [self.messageListView reloadData];
}


#pragma mark - InputBarControlDelegate
- (void)onInputBarControlContentSizeChanged:(CGRect)frame withAnimationDuration:(CGFloat)duration andAnimationCurve:(UIViewAnimationCurve)curve{
    [UIView animateWithDuration:0.2 animations:^{
        [UIView setAnimationCurve:curve];
        CGRect rect = self.messageListView.frame;
        CGFloat space = CGRectGetMaxY(rect)-CGRectGetMinY(frame);
        rect.size.height -=space;
        self.messageListView.frame = rect;
        [UIView commitAnimations];
    }];
    [self scrollToBottomWithAnimated:YES];
}

- (void)onTouchSendButton:(NSString *)text{
    RCTextMessage *textMsg = [RCTextMessage messageWithContent:text];
    [[MessageHelper sharedInstance] sendMessage:textMsg pushContent:nil pushData:nil
                                      toTargetId:self.targetId conversationType:self.conversationType];
    [self.inputBarControl clearInputView];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageModel *model = [self.dataSource objectAtIndex:indexPath.row];
    NSString *identifier = model.message.objectName?model.message.objectName:unknownMessageIdentifier;
    MessageBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[MessageBaseCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:model.message.objectName];
    }
    if ([[[MessageHelper sharedInstance] getAllSupportMessage] containsObject:model.message.objectName]) {
        [cell setDataModel:model];
    }else{
        //对于目前不支持的消息处理：删除所有子视图，表现为不展示
        [cell.baseContainerView removeFromSuperview];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageModel *model = [self.dataSource objectAtIndex:indexPath.row];
    if ([[[MessageHelper sharedInstance] getAllSupportMessage] containsObject:model.message.objectName]) {
        CGFloat topAndBottomSpace = 12;
        if ([model.message.content isKindOfClass:[TimeStampMessage class]]) {
            return model.contentSize.height+16;
        }else if ([model.message.content isKindOfClass:[RCTextMessage class]]){
            CGFloat userNameHeight = 16;
            CGFloat userNameAndContentSpace = 6;
            return model.contentSize.height+topAndBottomSpace+userNameHeight+userNameAndContentSpace;
        }else{
            return model.contentSize.height+topAndBottomSpace;
        }
    }else{
        //对于目前不支持的消息,高度为 0，表现为不展示
        return 0;
    }
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y <= 15 && !self.isLoadingHistoryMessage){
        [self.messageListView.mj_header beginRefreshing];
    }
    [self.inputBarControl setInputBarStatus:(InputBarControlStatusDefault)];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.messageListView scrollToRowAtIndexPath:firstIndexPath atScrollPosition:(UITableViewScrollPositionTop) animated:YES];
    return NO;
}

#pragma mark - helper
- (void)scrollToBottomWithAnimated:(BOOL)animated {
    if (self.dataSource.count > 0) {
        NSUInteger lastIndex = self.dataSource.count - 1;
        NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:lastIndex inSection:0];
        [self.messageListView  scrollToRowAtIndexPath:toIndexPath atScrollPosition:(UITableViewScrollPositionBottom) animated:animated];
    }
}

#pragma mark - Target action
- (void)didTap{
    [self.inputBarControl setInputBarStatus:InputBarControlStatusDefault];
}

- (void)loadHistoryData{
    [self.dataSource fetchHistoryMessages];
}

- (void)registerCell{
    [self.messageListView registerClass:[MessageBaseCell class] forCellReuseIdentifier:unknownMessageIdentifier];
    [self.messageListView registerClass:[TextMessageCell class] forCellReuseIdentifier:[RCTextMessage getObjectName]];
    [self.messageListView registerClass:[TimeStampCell class] forCellReuseIdentifier:[TimeStampMessage getObjectName]];
    [self.messageListView registerClass:[TipMessageCell class] forCellReuseIdentifier:[MemberChangeMessage getObjectName]];
    [self.messageListView registerClass:[TipMessageCell class] forCellReuseIdentifier:[RCInformationNotificationMessage getObjectName]];
}

#pragma mark - 键盘弹起，表情按钮超出父视图，无法点击
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint tp = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, tp)) {
                view = subView;
            }
        }
    }
    return view;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    CGPoint tp = [self.inputBarControl convertPoint:point fromView:self];
    //if内的条件应该为，当触摸点point超出蓝色部分，但在黄色部分时
    if (CGRectContainsPoint(self.inputBarControl.bounds, tp)) {
        return YES;
    }
    return NO;
}

#pragma mark - Getters and setters
- (UITableView *)messageListView{
    if (!_messageListView) {
        _messageListView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width, self.frame.size.height-HeighInputBar) style:(UITableViewStylePlain)];
        [_messageListView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _messageListView.estimatedRowHeight =0;
        _messageListView.estimatedSectionHeaderHeight =0;
        _messageListView.estimatedSectionFooterHeight =0;
        if (@available(iOS 11.0, *)) {
            _messageListView.insetsContentViewsToSafeArea = NO;
        }
        _messageListView.dataSource = self;
        _messageListView.delegate = self;
        _messageListView.backgroundColor = HEXCOLOR(0xe1e4e5);
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadHistoryData)];
        header.lastUpdatedTimeLabel.hidden = YES;
        header.stateLabel.hidden = YES;
        header.arrowView.hidden = YES;
        self.messageListView.mj_header = header;
    }
    return _messageListView;
}

- (InputBarControl *)inputBarControl{
    if (!_inputBarControl) {
        _inputBarControl = [[InputBarControl alloc] initWithStatus:InputBarControlStatusDefault];
        _inputBarControl.frame = CGRectMake(0,CGRectGetMaxY(self.messageListView.frame), self.frame.size.width, HeighInputBar);
        _inputBarControl.delegate = self;
    }
    return _inputBarControl;
}
@end
