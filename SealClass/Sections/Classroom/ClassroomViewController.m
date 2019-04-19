//
//  ClassViewController.m
//  SealClass
//
//  Created by LiFei on 2019/2/27.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "ClassroomViewController.h"
#import "ClassroomTitleView.h"
#import "ToolPanelView.h"
#import "RecentSharedView.h"
#import "PersonListView.h"
#import "VideoListView.h"
#import "MainContainerView.h"
#import "ChatAreaView.h"
#import "RTCService.h"
#import "UpgradeDidApplyView.h"
#import "UIView+MBProgressHUD.h"
#import "WhiteboardControl.h"
#import "Classroom.h"
#import "ClassroomService.h"
#import "NormalAlertView.h"
#import "LoginHelper.h"
#import "WhiteboardPopupView.h"
#import <MBProgressHUD/MBProgressHUD.h>
#define ToolPanelViewWidth    49
#define TitleViewHeight  64
#define RecentSharedViewWidth  133
#define PersonListViewWidth    240
#define VideoListViewWidth    112

@interface ClassroomViewController ()<ClassroomTitleViewDelegate, ToolPanelViewDelegate, RongRTCRoomDelegate, WhiteboardControlDelegate, ClassroomDelegate, RecentSharedViewDelegate, UpgradeDidApplyViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong) ClassroomTitleView *titleView;
@property (nonatomic, strong) ToolPanelView *toolPanelView;
@property (nonatomic, strong) RecentSharedView *recentSharedView;
@property (nonatomic, strong) PersonListView *personListView;
@property (nonatomic, strong) VideoListView *videoListView;
@property (nonatomic, strong) MainContainerView *containerView;
@property (nonatomic, strong) WhiteboardControl *wBoardCtrl;
@property (nonatomic, strong) ChatAreaView *chatAreaView;
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation ClassroomViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorWithHexString:@"1C272A" alpha:1];
    [super viewDidLoad];
    [self addSubviews];
    [self bindDelegates];
    [self publishStream];
    [self renderMainContainerView];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:tapGes];
    tapGes.delegate = self;
    [self showRoleHud];
}

- (void)tapGesture: (UITapGestureRecognizer *)tapGesture{
    for (UIButton *button in self.toolPanelView.buttonArray) {
        if (button.tag == ToolPanelViewActionTagVideoList || button.tag == ToolPanelViewActionTagOnlinePerson || button.tag == ToolPanelViewActionTagClassNews || button.tag == ToolPanelViewActionTagRecentlyShared) {
            if (button.selected) {
                button.selected = NO;
            }
        }
    }
    [self hideVideoListView];
    [self hidePersonListView];
    [self hideChatAreaView];
    [self hideRecentSharedView];
    [self refreshWboardFrame];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self.personListView] || [touch.view isDescendantOfView:self.videoListView] || [touch.view isDescendantOfView:self.recentSharedView]) {
        return NO;
    }
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refreshWboardFrame];
}

- (void)showRoleHud {
    Role role =  [ClassroomService sharedService].currentRoom.currentMember.role;
    if(role == RoleAudience) {
        [self.view showHUDMessage:NSLocalizedStringFromTable(@"Audience", @"SealClass", nil)];
        [self performSelector:@selector(showOnlyYouHUD) withObject:nil afterDelay:5.0f];
    }else{
        [self showOnlyYouHUD];
    }
}

- (void)showOnlyYouHUD {
    if ([ClassroomService sharedService].currentRoom.memberList.count == 1) {
        [self.view showHUDMessage:NSLocalizedStringFromTable(@"OnlyYou", @"SealClass", nil)];
    }
}

#pragma mark - RongRTCRoomDelegate
- (void)didPublishStreams:(NSArray <RongRTCAVInputStream *>*)streams {
    NSString *displayUserId;
    if (([ClassroomService sharedService].currentRoom.currentDisplayType == DisplayAssistant)) {
        displayUserId = [ClassroomService sharedService].currentRoom.assistant.userId;
    } else if (([ClassroomService sharedService].currentRoom.currentDisplayType == DisplayTeacher)) {
        displayUserId = [ClassroomService sharedService].currentRoom.teacher.userId;
    }
    for (RongRTCAVInputStream *stream in streams) {
        if ([stream.userId isEqualToString:displayUserId]) {
            [self renderMainContainerView];
        }
        [self.videoListView updateUserVideo:stream.userId];
    }
}
- (void)didConnectToStream:(RongRTCAVInputStream *)stream {
    NSLog(@"didConnectToStream userId:%@ streamID:%@",stream.userId,stream.userId);
}

- (void)didReportFirstKeyframe:(RongRTCAVInputStream *)stream {
    NSLog(@"didReportFirstKeyframe userId:%@ streamID:%@",stream.userId,stream.userId);
}

#pragma mark - ClassroomTitleViewDelegate
- (void)classroomTitleView:(UIButton *)button didTapAtTag:(ClassroomTitleViewActionTag)tag {
    [self.chatAreaView.inputBarControl setInputBarStatus:InputBarControlStatusDefault];
    switch (tag) {
        case ClassroomTitleViewActionTagSwitchCamera:
            [[RTCService sharedInstance] switchCamera];
            
            break;
        case ClassroomTitleViewActionTagMicrophone:
            [[RTCService sharedInstance] setMicrophoneDisable:button.selected];
            [[ClassroomService sharedService] enableDevice:!button.selected withType:DeviceTypeMicrophone];
            break;
        case ClassroomTitleViewActionTagCamera:
            [[RTCService sharedInstance] setCameraDisable:button.selected];
            [[ClassroomService sharedService] enableDevice:!button.selected withType:DeviceTypeCamera];
            
            break;
        case ClassroomTitleViewActionTagMute:
            [[RTCService sharedInstance] useSpeaker:!button.selected];
            
            break;
        case ClassroomTitleViewActionTagHangup:
        {
            [NormalAlertView showAlertWithTitle:NSLocalizedStringFromTable(@"LeaveRoom", @"SealClass", nil) leftTitle:NSLocalizedStringFromTable(@"Cancel", @"SealClass", nil) rightTitle:NSLocalizedStringFromTable(@"Leave", @"SealClass", nil) cancel:^{
                
            } confirm:^{
                SealClassLog(@"ActionTagHangup");
                self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [[LoginHelper sharedInstance] logout:^{
                    
                } error:^(RongRTCCode code) {
                    [self.hud hideAnimated:YES];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"LeaveFail", @"SealClass", nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"SealClass", nil) otherButtonTitles:nil];
                    [alertView show];
                }];
            }];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - ToolPanelViewDelegate
- (void)toolPanelView:(UIButton *)button didTapAtTag:(ToolPanelViewActionTag)tag {
    [self hideAllSubviewsOfToolPanelView];
    switch (tag) {
        case ToolPanelViewActionTagWhiteboard:
            if (button.selected) {
                button.selected = !button.selected;
                WhiteboardPopupView *popupView = [[WhiteboardPopupView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.toolPanelView.frame)+6, 50+25, 97, 44) shapePointY:44/2 items:@[@"新建白板"] didSelectItem:^(NSInteger index, NSString *item) {
                    switch (index) {
                        case 0:
                            [[ClassroomService sharedService] createWhiteboard];
                            break;
                        default:
                            break;
                    }
                }];
                [[UIApplication sharedApplication].keyWindow addSubview:popupView];
            }
            break;
        case ToolPanelViewActionTagRecentlyShared: {
            if(button.selected) {
                [[RTCService sharedInstance] refreshCurrentImage];
                [self showRecentSharedView];
                [self.recentSharedView reloadDataSource];
            }else {
                [self hideRecentSharedView];
            }
        }
            
            break;
        case ToolPanelViewActionTagOnlinePerson:
            button.selected ? [self showPersonListView] : [self hidePersonListView];
            
            break;
        case ToolPanelViewActionTagVideoList: {
            if(button.selected) {
                [self showVideoListView];
            }else {
                [self hideVideoListView];
            }
        }
            
            break;
        case ToolPanelViewActionTagClassNews:
            button.selected ? [self showChatAreaView] : [self hideChatAreaView];
            
            break;
        default:
            
            break;
    }
    [self refreshWboardFrame];
}

- (void)hideAllSubviewsOfToolPanelView {
    [self hideRecentSharedView];
    [self hidePersonListView];
    [self hideVideoListView];
    [self hideChatAreaView];
}

#pragma mark - RecentSharedViewDelegate
- (void)recentSharedViewCellTap:(id)recentShared {
    if ([recentShared isKindOfClass:[Whiteboard class]]) {
        [[RTCService sharedInstance] cancelRenderVideoInView:self.containerView.videoView];
        Whiteboard *whiteBoard = (Whiteboard *)recentShared;
        [self displayWhiteboard:whiteBoard.boardId];
        [[ClassroomService sharedService] displayWhiteboard:whiteBoard.boardId];
        [self.videoListView showAssistantPrompt:NO showTeacherPrompt:NO];
        
    } else if ([recentShared isKindOfClass:[RoomMember class]]) {
        RoomMember *member = (RoomMember *)recentShared;
        [self.wBoardCtrl hideBoard];
        [self.containerView containerViewRenderView:member];
        switch (member.role) {
            case RoleAssistant:
                [[ClassroomService sharedService] displayAssistant];
                [self.videoListView showAssistantPrompt:YES showTeacherPrompt:NO];
                break;
            case RoleTeacher:
                [[ClassroomService sharedService] displayTeacher];
                [self.videoListView showAssistantPrompt:NO showTeacherPrompt:YES];
                break;
            default:
                break;
        }
    }
}

#pragma mark - UpgradeDidApplyViewDelegate
- (void)upgradeDidApplyView:(UpgradeDidApplyView *)topView didTapAtTag:(UpgradeDidApplyViewActionTag)tag {
    if (tag == UpgradeDidApplyViewAccept) {
        [[ClassroomService sharedService] approveUpgrade:topView.ticket];
    }else {
        [[ClassroomService sharedService] rejectUpgrade:topView.ticket];
    }
    [self dismissTopAlertView:topView];
}

#pragma mark - WhiteboardControlDelegate

- (void)didTurnPage:(NSInteger)pageNum {
}

#pragma mark - ClassroomDelegate
- (void)roomDidLeave {
    NSLog(@"roomDidLeave");
    [self.hud hideAnimated:YES];
    if ([RTCService sharedInstance].rtcRoom) {
        [[RTCService sharedInstance] leaveRongRTCRoom:[ClassroomService sharedService].currentRoom.roomId success:^{
            
        } error:^(RongRTCCode code) {
            
        }];
        [[RCIMClient sharedRCIMClient] disconnect];
    }
    [self dismissViewControllerAnimated:NO completion:^{
        [self.titleView stopDurationTimer];
    }];
    
}

- (void)memberDidJoin:(RoomMember *)member {
    NSLog(@"memberDidJoin %@",member);
    [self.videoListView reloadVideoList];
    [self.personListView reloadPersonList];
    if (member.role == RoleTeacher || member.role == RoleAssistant) {
        [self.recentSharedView reloadDataSource];
    }
}

- (void)memberDidLeave:(RoomMember *)member {
    NSLog(@"memberDidLeave %@",member);
    [self.videoListView reloadVideoList];
    [self.personListView reloadPersonList:member tag:RefreshPersonListTagRemove];
    if (member.role == RoleTeacher || member.role == RoleAssistant) {
        [self.recentSharedView reloadDataSource];
    }
}

- (void)memberDidKick:(RoomMember *)member {
    NSLog(@"memberDidKick %@",member);
    if ([ClassroomService sharedService].currentRoom.currentMember.role == RoleAssistant) {
        [self.view showHUDMessage:[NSString stringWithFormat:NSLocalizedStringFromTable(@"YouDeletePersonSuccess", @"SealClass", nil),member.name]];
    }
    [self.videoListView reloadVideoList];
    [self.personListView reloadPersonList:member tag:RefreshPersonListTagRemove];
    if (member.role == RoleTeacher || member.role == RoleAssistant) {
        [self.recentSharedView reloadDataSource];
    }
    if (self.containerView.member.role == member.role) {
        [self.containerView cancelRenderView];
    }
}

- (void)errorDidOccur:(ErrorCode)code {
    NSLog(@"errorDidOccur %@",@(code));
    [self.hud hideAnimated:YES];
    if (code != ErrorCodeSuccess) {
        if (code == ErrorCodeOverMaxUserCount) {
            [self.view showHUDMessage:NSLocalizedStringFromTable(@"ErrorCodeOverMaxUserCount", @"SealClass", nil)];
        }else {
            [self.view showHUDMessage:NSLocalizedStringFromTable(@"Error", @"SealClass", nil)];
        }
    }
}

- (void)roleDidChange:(Role)role forUser:(RoomMember *)member {
    NSLog(@"roleDidChange:%@ member:%@",@(role),member);
    RoomMember *curMember = [ClassroomService sharedService].currentRoom.currentMember;
    switch (role) {
        case RoleAssistant:
            if ([curMember.userId isEqualToString:member.userId]) {
                [self.view showHUDMessage:NSLocalizedStringFromTable(@"YouTransfer", @"SealClass", nil)];
            }
            break;
        case RoleTeacher:
            if (curMember.role == RoleAssistant) {
                [self.view showHUDMessage:[NSString stringWithFormat:NSLocalizedStringFromTable(@"YouSetTeacherSuccess", @"SealClass", nil),member.name]];
            }else {
                if ([curMember.userId isEqualToString:member.userId]) {
                    [self.view showHUDMessage:NSLocalizedStringFromTable(@"YouTeacher", @"SealClass", nil)];
                }
            }
            break;
        case RoleStudent:
            //申请发言和邀请升级都会走.转让助教，老助教变成学员不走这里
            if ([curMember.userId isEqualToString:member.userId]) {
                [self.view showHUDMessage:NSLocalizedStringFromTable(@"YouStudent", @"SealClass", nil)];
                [[RTCService sharedInstance] useSpeaker:YES];
                [[RTCService sharedInstance] setCameraDisable:NO];
                [[RTCService sharedInstance] setMicrophoneDisable:NO];
                [[RTCService sharedInstance] publishLocalUserDefaultAVStream];
                [self.titleView refreshTitleView];
            }else {
                [self.view showHUDMessage:[NSString stringWithFormat:NSLocalizedStringFromTable(@"PersonStudent", @"SealClass", nil),member.name]];
            }
            
            break;
        case RoleAudience:
            if (curMember.role == RoleAssistant) {
                [self.view showHUDMessage:[NSString stringWithFormat:NSLocalizedStringFromTable(@"YouSetAudienceSuccess", @"SealClass", nil),member.name]];
            } else {
                if ([curMember.userId isEqualToString:member.userId]) {
                    [self.titleView refreshTitleView];
                    [self hideRecentSharedView];
                    [self.view showHUDMessage:NSLocalizedStringFromTable(@"YouDowngraded", @"SealClass", nil)];
                    [[RTCService sharedInstance] useSpeaker:NO];
                    [[RTCService sharedInstance] setCameraDisable:YES];
                    [[RTCService sharedInstance] setMicrophoneDisable:YES];
                    [[RTCService sharedInstance] unpublishLocalUserDefaultAVStream];
                }
            }
            break;
    }
    [self.toolPanelView reloadToolPanelView];
    [self.personListView reloadPersonList];
    [self.videoListView reloadVideoList];
    if (role == RoleTeacher || role == RoleAssistant) {
        [self.recentSharedView reloadDataSource];
    }
    if ([member.userId isEqualToString:[ClassroomService sharedService].currentRoom.currentMember.userId]) {
        [self.wBoardCtrl didChangeRole:role];
        [self.containerView didChangeRole:role];
    }
    if (member.userId) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RoleDidChangeNotification object:@{@"role":@(role),@"userId":member.userId}];
    }
}

//转让助教的回调
- (void)assistantDidTransfer:(RoomMember *)oldAssistant newAssistant:(RoomMember *)newAssistant {
    NSLog(@"assistantDidTransfer from:%@ to:%@",oldAssistant,newAssistant);
    RoomMember *curMember = [ClassroomService sharedService].currentRoom.currentMember;
    if ([curMember.userId isEqualToString:oldAssistant.userId]) {
        [self.view showHUDMessage:[NSString stringWithFormat:NSLocalizedStringFromTable(@"YouSetTransferSuccess", @"SealClass", nil),newAssistant.name]];
    }
    [self.personListView reloadPersonList];
    [self.videoListView reloadVideoList];
}

//旁观者申请成为学员，助教收到的回调
- (void)upgradeDidApply:(RoomMember *)member ticket:(NSString *)ticket overMaxCount:(BOOL)isOver{
    NSLog(@"upgradeDidApply:%@ ticket:%@ overMaxCount:%@",member,ticket,@(isOver));
    if (isOver) {
        NSString * title = [NSString stringWithFormat:@"%@ %@",member.name ,NSLocalizedStringFromTable(@"ApplaySpeakerAbove", @"SealClass", nil)];
        [NormalAlertView showAlertWithTitle:title leftTitle:NSLocalizedStringFromTable(@"RefuseRequest", @"SealClass", nil) rightTitle:NSLocalizedStringFromTable(@"Close", @"SealClass", nil) cancel:^{
            [[ClassroomService sharedService] rejectUpgrade:ticket];
        } confirm:^{
            
        }];
    }else {
        UpgradeDidApplyView *alertView =  [[UpgradeDidApplyView alloc] initWithMember:member ticket:ticket];
        [self.view addSubview:alertView];
        alertView.delegate = self;
        [self performSelector:@selector(dismissTopAlertView:) withObject:alertView afterDelay:30.0];
    }
}

//旁观者申请成为学员，助教接受的回调
- (void)applyDidApprove {
    NSLog(@"applyDidApprove %@",[ClassroomService sharedService].currentRoom.currentMember);
    [[RTCService sharedInstance] useSpeaker:YES];
    [[RTCService sharedInstance] setCameraDisable:NO];
    [[RTCService sharedInstance] setMicrophoneDisable:NO];
    [[RTCService sharedInstance] publishLocalUserDefaultAVStream];
    self.personListView.curMemberApplying = NO;
    [self.personListView reloadPersonList:[ClassroomService sharedService].currentRoom.currentMember tag:RefreshPersonListTagRefresh];
}

//旁观者申请成为学员，助教拒绝的回调
- (void)applyDidReject {
    NSLog(@"applyDidReject %@",[ClassroomService sharedService].currentRoom.currentMember);
    [self.view showHUDMessage:NSLocalizedStringFromTable(@"YouUpgradedReject", @"SealClass", nil)];
    self.personListView.curMemberApplying = NO;
    [self.personListView reloadPersonList:[ClassroomService sharedService].currentRoom.currentMember tag:RefreshPersonListTagRefresh];
    
}

//旁观者申请成为学员失败的回调
- (void)applyDidFailed:(ErrorCode)code {
    NSLog(@"applyDidFailed %@",[ClassroomService sharedService].currentRoom.currentMember);
    [self.view showHUDMessage:NSLocalizedStringFromTable(@"Error", @"SealClass", nil)];
    self.personListView.curMemberApplying = NO;
    [self.personListView reloadPersonList:[ClassroomService sharedService].currentRoom.currentMember tag:RefreshPersonListTagRefresh];
}

//助教邀请旁观者成为学员,旁观者收到的回调
- (void)upgradeDidInvite:(NSString *)ticket {
    NSLog(@"upgradeDidInvite ticket:%@ member:%@",ticket,[ClassroomService sharedService].currentRoom.currentMember);
    [NormalAlertView showAlertWithTitle:NSLocalizedStringFromTable(@"InviteUpgrade", @"SealClass", nil) leftTitle:NSLocalizedStringFromTable(@"Refuse", @"SealClass", nil) rightTitle:NSLocalizedStringFromTable(@"Agreen", @"SealClass", nil) cancel:^{
        [[ClassroomService sharedService] rejectInvite:ticket];
        
    } confirm:^{
        [[ClassroomService sharedService] approveInvite:ticket];
    }];
}

//助教邀请旁观者成为学员，旁观者接受的回调
- (void)inviteDidApprove:(RoomMember *)member {
    NSLog(@"inviteDidApprove :%@",member);
    [self.view showHUDMessage:[NSString stringWithFormat:NSLocalizedStringFromTable(@"SetStudentSuccess", @"SealClass", nil),member.name]];
    
}

//助教邀请旁观者成为学员，旁观者拒绝的回调
- (void)inviteDidReject:(RoomMember *)member {
    NSLog(@"inviteDidReject :%@",member);
    [self.view showHUDMessage:NSLocalizedStringFromTable(@"RefuseYourInvite", @"SealClass", nil)];
}

//旁观者申请成为学员/助教邀请旁观者成为学员，超时没有回应的回调
- (void)ticketDidExpire:(NSString *)ticket {
    NSLog(@"ticketDidExpire ticket:%@",ticket);
    [self.view showHUDMessage:NSLocalizedStringFromTable(@"OverTime", @"SealClass", nil)];
    self.personListView.curMemberApplying = NO;
    [self.personListView reloadPersonList];
}

- (void)deviceDidEnable:(BOOL)enable type:(DeviceType)type forUser:(RoomMember *)member operator:(nonnull NSString *)operatorId{
    NSLog(@"deviceDidEnable devicetype:%@ enable:%@ memeber:%@",@(type),@(enable),member);
    RoomMember *curMember = [ClassroomService sharedService].currentRoom.currentMember;
    NSString *hudMessage = @"";
    //只有助教和自己才有提示
    if (curMember.role == RoleAssistant && ![curMember.userId isEqualToString:operatorId]) {
        if (type == DeviceTypeCamera) {
            hudMessage = !enable ? [NSString stringWithFormat:NSLocalizedStringFromTable(@"SetCameraClose", @"SealClass", nil),member.name] : [NSString stringWithFormat:NSLocalizedStringFromTable(@"SetCameraOpen", @"SealClass", nil),member.name];
        } else {
            hudMessage = !enable ? [NSString stringWithFormat:NSLocalizedStringFromTable(@"SetMicorophoneClose", @"SealClass", nil),member.name] : [NSString stringWithFormat:NSLocalizedStringFromTable(@"SetMicorophoneOpen", @"SealClass", nil),member.name];
        }
        [self.view showHUDMessage:hudMessage];
    }else {
        if ([curMember.userId isEqualToString:member.userId]) {
            if (type == DeviceTypeCamera) {
                if(![curMember.userId isEqualToString:operatorId]){
                    hudMessage = !enable ? NSLocalizedStringFromTable(@"YourCameraClosed", @"SealClass", nil) : NSLocalizedStringFromTable(@"CameraOpend", @"SealClass", nil);
                    [self.view showHUDMessage:hudMessage];
                }
                self.titleView.cameraBtn.selected = enable;
                [[RTCService sharedInstance] setCameraDisable:!enable];
            } else {
                if(![curMember.userId isEqualToString:operatorId]){
                    hudMessage = !enable ? NSLocalizedStringFromTable(@"YourMicorophoneClosed", @"SealClass", nil) : NSLocalizedStringFromTable(@"MicorophoneOpend", @"SealClass", nil);
                    [self.view showHUDMessage:hudMessage];
                }
                self.titleView.microphoneBtn.selected = enable;
                [[RTCService sharedInstance] setMicrophoneDisable:!enable];
            }
        }
    }
    if ([ClassroomService sharedService].currentRoom.currentDisplayType != DisplayWhiteboard && type == DeviceTypeCamera) {
        [self renderMainContainerView];
    }
    [self.titleView refreshTitleView];
    [self.personListView reloadPersonList:member tag:RefreshPersonListTagRefresh];
}

//助教请求用户打开设备，助教关闭用户设备没有回调。
- (void)deviceDidInviteEnable:(DeviceType)type ticket:(NSString *)ticket{
    NSLog(@"deviceDidInviteEnable devicetype:%@ ticket:%@ ",@(type),ticket);
    if (type == DeviceTypeCamera) {
        [NormalAlertView showAlertWithTitle:NSLocalizedStringFromTable(@"AssitantInviteCamera", @"SealClass", nil) leftTitle:NSLocalizedStringFromTable(@"Refuse", @"SealClass", nil) rightTitle:NSLocalizedStringFromTable(@"Agreen", @"SealClass", nil) cancel:^{
            [[ClassroomService sharedService] rejectEnableDevice:ticket];
        } confirm:^{
            [[ClassroomService sharedService] approveEnableDevice:ticket];
        }];
    }else {
        [NormalAlertView showAlertWithTitle:NSLocalizedStringFromTable(@"AssitantInviteMicro", @"SealClass", nil) leftTitle:NSLocalizedStringFromTable(@"Refuse", @"SealClass", nil) rightTitle:NSLocalizedStringFromTable(@"Agreen", @"SealClass", nil) cancel:^{
            [[ClassroomService sharedService] rejectEnableDevice:ticket];
        } confirm:^{
            [[ClassroomService sharedService] approveEnableDevice:ticket];
        }];
    }
}

//只有助教能收到这个回调,可以不在这里处理文字，因为设备的回调还会走
- (void)deviceInviteEnableDidApprove:(RoomMember *)member type:(DeviceType)type {
    NSLog(@"deviceInviteEnableDidApprove devicetype:%@ member:%@ ",@(type),member);
    //    if (type == DeviceTypeCamera) {
    //        [self.view showHUDMessage:[NSString stringWithFormat:NSLocalizedStringFromTable(@"SetCameraOpen", @"SealClass", nil),member.name]];
    //    }
    //    if (type == DeviceTypeMicrophone) {
    //        [self.view showHUDMessage:[NSString stringWithFormat:NSLocalizedStringFromTable(@"SetMicorophoneOpen", @"SealClass", nil),member.name]];
    //    }
}

//拒绝只有助教能收到这个回调，且只走这个回调
- (void)deviceInviteEnableDidReject:(RoomMember *)member type:(DeviceType)type {
    NSLog(@"deviceInviteEnableDidReject devicetype:%@ member:%@ ",@(type),member);
    [self.view showHUDMessage:[NSString stringWithFormat:NSLocalizedStringFromTable(@"RefuseYourInvite", @"SealClass", nil),member.name]];
}

- (void)whiteboardDidCreate:(Whiteboard *)board {
    NSLog(@"whiteboardDidCreate %@ ",board);
    [self.recentSharedView reloadDataSource];
}

- (void)whiteboardDidDisplay:(NSString *)boardId {
    NSLog(@"whiteboardDidDisplay %@ ",boardId);
    [self renderMainContainerView];
}

- (void)whiteboardDidDelete:(Whiteboard *)board {
    NSLog(@"whiteboardDidDelete %@ ", board);
    [self.recentSharedView reloadDataSource];
}

- (void)teacherDidDisplay {
    NSLog(@"teacherDidDisplay %@ ",[ClassroomService sharedService].currentRoom.teacher);
    [self renderMainContainerView];
}

- (void)assistantDidDisplay {
    NSLog(@"assistantDidDisplay %@ ",[ClassroomService sharedService].currentRoom.assistant);
    [self renderMainContainerView];
}

- (void)sharedScreenDidDisplay:(NSString *)userId {
    NSLog(@"sharedScreenDidDisplay %@ ",userId);
    [self renderMainContainerView];
}

- (void)noneDidDisplay {
    NSLog(@"noneDidDisplay");
    [self renderMainContainerView];
}

#pragma mark - private method

- (void)bindDelegates {
    self.titleView.delegate = self;
    self.toolPanelView.delegate = self;
    [[RTCService sharedInstance] setRTCRoomDelegate:self];
    [ClassroomService sharedService].classroomDelegate = self;
}

- (void)addSubviews {
    [self.view addSubview:self.titleView];
    [self.view addSubview:self.toolPanelView];
    [self.view addSubview:self.containerView];
    [self chatAreaView];
    [self.view addSubview:self.videoListView];
    for (UIButton *button in self.toolPanelView.buttonArray) {
        if (button.tag == ToolPanelViewActionTagVideoList) {
            button.selected = YES;
        }
    }
}

- (void)showRecentSharedView {
    [self.view addSubview:self.recentSharedView];;
}

- (void)showPersonListView {
    [self.view addSubview:self.personListView];
}

- (void)showVideoListView {
    [self.view addSubview:self.videoListView];
}

- (void)showChatAreaView{
    [self.view addSubview:self.chatAreaView];
}

- (void)hideRecentSharedView {
    [self.recentSharedView removeFromSuperview];
}

- (void)hidePersonListView {
    [self.personListView removeFromSuperview];
}

- (void)hideVideoListView {
    [self.videoListView removeFromSuperview];
}

- (void)hideChatAreaView{
    [UIView animateWithDuration:0.2 animations:^{
        [self.chatAreaView removeFromSuperview];
    }];
}

- (CGRect)mainContainerFrame {
    CGFloat x = CGRectGetMaxX(self.toolPanelView.frame);
    CGFloat y = TitleViewHeight;
    CGFloat width = UIScreenWidth - x;
    CGFloat height = UIScreenHeight - y;
    return CGRectMake(x, y, width, height);
}

- (void)dismissTopAlertView:(UpgradeDidApplyView*)topAlertView {
    [topAlertView removeFromSuperview];
    topAlertView = nil;
}

- (void)displayWhiteboard:(NSString *)boardId {
    NSString *urlStr = [[ClassroomService sharedService] generateWhiteboardURL:boardId];
    [self.wBoardCtrl loadWBoardWith:boardId wBoardURL:urlStr superView:self.view frame:CGRectZero];
    [self refreshWboardFrame];
    for (UIView * view in self.view.subviews) {
        if ([view isKindOfClass:[PersonListView class]]) {
            [self.view bringSubviewToFront:view];
        }
    }
}

- (void)refreshWboardFrame {
    CGRect rect;
    CGRect mianContainRect = [self mainContainerFrame];
    CGFloat originX = (mianContainRect.size.width-RecentSharedViewWidth-750/2)/2+CGRectGetMaxX(self.toolPanelView.frame);
    CGFloat originY = (UIScreenHeight-TitleViewHeight-563/2)/2+TitleViewHeight;
    if (self.recentSharedView.superview) {
        rect = CGRectMake(originX+90, originY, 750/2, 563/2);
        [self.containerView moveVideoViewTo:90];
    }else{
        rect = CGRectMake(originX, originY, 750/2, 563/2);
        [self.containerView moveVideoViewTo:0];
    }
    [self.wBoardCtrl setWBoardFrame:rect];
}

- (CGFloat)getIphoneXFitSpace{
    static CGFloat space;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 11.0, *)) {
            UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
            UIEdgeInsets safeAreaInsets = mainWindow.safeAreaInsets;
            if (!UIEdgeInsetsEqualToEdgeInsets(safeAreaInsets,UIEdgeInsetsZero)){
                space = 34;
            }
        }});
    return space;
}

- (void)publishStream {
    if ([ClassroomService sharedService].currentRoom.currentMember.role != RoleAudience) {
        [[RTCService sharedInstance] publishLocalUserDefaultAVStream];
    }
}

- (void)renderMainContainerView{
    RoomMember *assistant = [ClassroomService sharedService].currentRoom.assistant;
    RoomMember *teacher = [ClassroomService sharedService].currentRoom.teacher;
    if (([ClassroomService sharedService].currentRoom.currentDisplayType == DisplayAssistant) && assistant.cameraEnable) {
        [self.wBoardCtrl hideBoard];
        [self.containerView containerViewRenderView:[ClassroomService sharedService].currentRoom.assistant];
        [self.videoListView showAssistantPrompt:YES showTeacherPrompt:NO];
    } else if (([ClassroomService sharedService].currentRoom.currentDisplayType == DisplayTeacher && teacher.cameraEnable)) {
        [self.wBoardCtrl hideBoard];
        [self.containerView containerViewRenderView:[ClassroomService sharedService].currentRoom.teacher];
        [self.videoListView showAssistantPrompt:NO showTeacherPrompt:YES];
    } else if ([ClassroomService sharedService].currentRoom.currentDisplayType == DisplayWhiteboard) {
        [self.containerView cancelRenderView];
        [self displayWhiteboard:[ClassroomService sharedService].currentRoom.currentDisplayURI];
        [self.videoListView showAssistantPrompt:NO showTeacherPrompt:NO];
    } else if (([ClassroomService sharedService].currentRoom.currentDisplayType == DisplaySharedScreen)) {
        [self.wBoardCtrl hideBoard];
        [[RTCService sharedInstance] renderUserSharedScreenOnView:self.containerView.videoView forUser:[ClassroomService sharedService].currentRoom.currentDisplayURI];
        [self.videoListView showAssistantPrompt:NO showTeacherPrompt:NO];
    } else {
        [self.wBoardCtrl hideBoard];
        [self.containerView cancelRenderView];
    }
}

#pragma mark - Getters & setters

- (ClassroomTitleView *)titleView {
    if(!_titleView) {
        _titleView = [[ClassroomTitleView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.toolPanelView.frame), 0, UIScreenWidth - CGRectGetMaxX(self.toolPanelView.frame), TitleViewHeight)];
    }
    return _titleView;
}

- (ToolPanelView *)toolPanelView {
    if(!_toolPanelView) {
        _toolPanelView = [[ToolPanelView alloc] initWithFrame:CGRectMake([self getIphoneXFitSpace], 0, ToolPanelViewWidth, UIScreenHeight)];
    }
    return _toolPanelView;
}

- (RecentSharedView *)recentSharedView {
    if(!_recentSharedView) {
        _recentSharedView = [[RecentSharedView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.toolPanelView.frame), 0, RecentSharedViewWidth, UIScreenHeight)];
        _recentSharedView.delegate = self;
    }
    return _recentSharedView;
}

- (PersonListView *)personListView {
    if(!_personListView) {
        _personListView = [[PersonListView alloc] initWithFrame:CGRectMake(UIScreenWidth - PersonListViewWidth, 0, PersonListViewWidth, UIScreenHeight)];
    }
    return _personListView;
}

- (VideoListView *)videoListView {
    if(!_videoListView) {
        _videoListView = [[VideoListView alloc] initWithFrame:CGRectMake(UIScreenWidth - VideoListViewWidth - 20, TitleViewHeight, VideoListViewWidth, UIScreenHeight - TitleViewHeight)];
    }
    return _videoListView;
}

- (MainContainerView *)containerView {
    if(!_containerView) {
        _containerView = [[MainContainerView alloc] initWithFrame:[self mainContainerFrame]];
    }
    return _containerView;
}

- (ChatAreaView *)chatAreaView {
    if(!_chatAreaView) {
        _chatAreaView = [[ChatAreaView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.toolPanelView.frame),TitleViewHeight, UIScreenWidth - CGRectGetMaxX(self.toolPanelView.frame), UIScreenHeight-TitleViewHeight) conversationType:ConversationType_GROUP targetId:[ClassroomService sharedService].currentRoom.roomId];
    }
    return _chatAreaView;
}

- (WhiteboardControl *)wBoardCtrl {
    if (!_wBoardCtrl) {
        _wBoardCtrl = [[WhiteboardControl alloc] initWithDelegate:self];
    }
    return _wBoardCtrl;
}

@end
