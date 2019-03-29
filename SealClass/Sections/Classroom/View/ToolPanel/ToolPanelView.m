//
//  ToolPanelView.m
//  SealClass
//
//  Created by Sin on 2019/2/28.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "ToolPanelView.h"
#import "ClassroomService.h"
#import <RongIMLib/RongIMLib.h>
#define LLeftButtonCount     5
#define LLeftButtonWidht     24
#define LLeftButtonMargin    24
#define LLeftToolViewHight   (5 * 24 + 7 * 24)

@interface ToolPanelView ()

@property (nonatomic, strong) UIView *toolView;
@property (nonatomic, strong) NSArray *buttonImageArray;
@property (nonatomic, strong) NSArray *buttonSelectedImageArray;
@property (nonatomic, strong) NSArray *buttonOpenHighlightedImageArray;
@property (nonatomic, strong) NSArray *buttonHighlightedImageArray;

@end

@implementation ToolPanelView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"293A3D" alpha:0.95];
        [self addSubviews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveMessageNotification:) name:OnReceiveMessageNotification object:nil];
    }
    return self;
}

- (void)onReceiveMessageNotification:(NSNotification *)notification{
    NSDictionary *dic = notification.object;
    RCMessage *message = dic[@"message"];
    Classroom *currentRoom = [ClassroomService sharedService].currentRoom;
    if ([message.targetId isEqualToString:currentRoom.roomId]) {
        dispatch_main_async_safe(^{
            [self updateClassNewsButton];
        });
    }
}

- (void)addSubviews {
    [self addSubview:self.toolView];
    [self addButtonsIn:self.toolView];
}
- (void)tapEvent:(UIButton *)btn {
    for (UIButton *button in self.buttonArray) {
        if (button.tag != btn.tag) {
            if (button.tag == ToolPanelViewActionTagClassNews && button.selected) {
                [self clearUnreadMessage];
            }
            button.selected = NO;
        }else{
            [self clearUnreadMessage];
        }
    }
    btn.selected = !btn.selected;
    if(self.delegate && [self.delegate respondsToSelector:@selector(toolPanelView:didTapAtTag:)]) {
        [self.delegate toolPanelView:btn didTapAtTag:btn.tag];
    }
}

- (void)updateClassNewsButton{
    Classroom *currentRoom = [ClassroomService sharedService].currentRoom;
    int unreadCount = [[RCIMClient sharedRCIMClient] getUnreadCount:ConversationType_GROUP targetId:currentRoom.roomId];
    UIButton *button = (UIButton *)[self viewWithTag:ToolPanelViewActionTagClassNews];
    if (unreadCount > 0 && !button.selected) {
        [button setBackgroundImage:[UIImage imageNamed:@"classnews_unread"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"classnews_unread_pressed"] forState:UIControlStateHighlighted];
    }else{
        [button setBackgroundImage:[UIImage imageNamed:@"classnews"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"classnews_selected"] forState:UIControlStateHighlighted];
    }
}

- (void)clearUnreadMessage{
    Classroom *currentRoom = [ClassroomService sharedService].currentRoom;
    [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_GROUP targetId:currentRoom.roomId];
    UIButton *button = (UIButton *)[self viewWithTag:ToolPanelViewActionTagClassNews];
    [button setBackgroundImage:[UIImage imageNamed:@"classnews"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"classnews_selected"] forState:UIControlStateHighlighted];
}

- (void)addButtonsIn:(UIView *)toolView; {
    self.buttonArray = [[NSMutableArray alloc] init];
    CGFloat buttonX = (self.bounds.size.width - LLeftButtonWidht ) / 2.0;
    self.buttonImageArray = @[@"whiteboard", @"recentlyshared", @"onlineperson", @"videolist", @"classnews"];
    self.buttonSelectedImageArray = @[@"whiteboard_disable", @"recentlyshared_open", @"onlineperson_open", @"videolist_open", @"classnews_open"];
    self.buttonOpenHighlightedImageArray = @[@"whiteboard_selected", @"recentlyshared_open_selected", @"onlineperson_open_selected", @"videolist_open_selected", @"classnews_open_selected"];
    self.buttonHighlightedImageArray = @[@"whiteboard_selected", @"recentlyshared_selected", @"onlineperson_selected", @"videolist_selected", @"classnews_selected"];
    
    for(int i = 0; i < LLeftButtonCount; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, LLeftButtonMargin + i * (LLeftButtonWidht + LLeftButtonMargin), LLeftButtonWidht, LLeftButtonWidht)];
        button.tag = i;
        [button setBackgroundImage:[UIImage imageNamed:[self.buttonImageArray objectAtIndex:i]] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:[self.buttonSelectedImageArray objectAtIndex:i]]  forState:UIControlStateSelected];
        [button setBackgroundImage:[UIImage imageNamed:[self.buttonHighlightedImageArray objectAtIndex:i]] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage imageNamed:[self.buttonOpenHighlightedImageArray objectAtIndex:i]] forState:(UIControlStateHighlighted|UIControlStateSelected)];
        [button addTarget:self action:@selector(tapEvent:) forControlEvents:UIControlEventTouchUpInside];
        [toolView addSubview:button];
        [self.buttonArray addObject:button];
        [self setButtonImage];
    }
    
}
- (void)setButtonImage {
    RoomMember *currentMember = [ClassroomService sharedService].currentRoom.currentMember;
    for (UIButton * button in self.buttonArray) {
        if (button.tag == ToolPanelViewActionTagWhiteboard) {
            if (currentMember.role != RoleAssistant && currentMember.role !=RoleTeacher) {
                [button setBackgroundImage:[UIImage imageNamed:@"whiteboard_disable"] forState:UIControlStateNormal];
                button.enabled = NO;
            }else {
                button.enabled = YES;
                [button setBackgroundImage:[UIImage imageNamed:@"whiteboard"] forState:UIControlStateNormal];
            }
        }
        if (button.tag == ToolPanelViewActionTagRecentlyShared) {
            if (currentMember.role != RoleAssistant && currentMember.role !=RoleTeacher) {
                [button setBackgroundImage:[UIImage imageNamed:@"recentlyshared_disable"] forState:UIControlStateNormal];
                button.enabled = NO;
            }else {
                button.enabled = YES;
                [button setBackgroundImage:[UIImage imageNamed:@"recentlyshared"] forState:UIControlStateNormal];
            }
        }
    }
}

- (void)reloadToolPanelView {
    [self setButtonImage];
}

- (UIView *)toolView {
    if(!_toolView) {
        CGSize size = self.bounds.size;
        _toolView = [[UIView alloc] initWithFrame:CGRectMake(0, (size.height - LLeftToolViewHight) / 2, size.width, LLeftToolViewHight)];
    }
    return _toolView;
}

@end
