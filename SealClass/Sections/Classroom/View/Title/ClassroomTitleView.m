//
//  ClassroomTitleView.m
//  SealClass
//
//  Created by Sin on 2019/2/28.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "ClassroomTitleView.h"
#import "ClassroomService.h"
#import "Masonry.h"
#import <AVFoundation/AVFoundation.h>

#define TSignalImageViewWidth   12
#define TTimeLableWidth   50
#define TTimeLableHeight  14
#define TTitleViewWidth   100
#define TTitleViewHeight   24
#define TToolViewWidth   (5 * 22 + 5 * 20)
#define TButtonCount     5
#define TButtonWidht     22

@interface ClassroomTitleView ()

@property (nonatomic, strong) UIImageView *signalImageView;
@property (nonatomic, strong) UILabel *timeLable;
@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UIView *toolView;
@property (nonatomic, strong) NSTimer *timeTimer;
@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, strong) NSArray *buttonImageArray;
@property (nonatomic, strong) NSArray *buttonHighlightedImageArray;
@property (nonatomic, strong) NSArray *buttonCloseImageArray;
@property (nonatomic, assign) NSInteger duration;

@end

@implementation ClassroomTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CAGradientLayer * gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(__bridge id)[UIColor colorWithHexString:@"262F38" alpha:0.01].CGColor,(__bridge id)[UIColor colorWithHexString:@"262F38" alpha:1].CGColor];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1);
        gradientLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.6];
        self.duration = 0;
        [self.layer addSublayer:gradientLayer];
        [self.buttonArray addObjectsFromArray:@[self.switchCameraBtn,self.microphoneBtn,self.cameraBtn,self.muteBtn,self.hangupBtn]];
        [self addSubviews];
        [self refreshTitleView];
        [self.timeTimer setFireDate:[NSDate distantPast]];
    }
    return self;
}

- (void)addSubviews {
    [self addSubview:self.signalImageView];
    [self addSubview:self.timeLable];
    [self addSubview:self.titleLable];
    [self addSubview:self.toolView];
    [self.toolView addSubview:self.switchCameraBtn];
    [self.toolView addSubview:self.microphoneBtn];
    [self.toolView addSubview:self.cameraBtn];
    [self.toolView addSubview:self.muteBtn];
    [self.toolView addSubview:self.hangupBtn];
    CGFloat topOffset = (self.bounds.size.height - TButtonWidht ) / 2.0;
    
    [self.signalImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(10);
        make.centerY.equalTo(self.mas_centerY);
        make.width.equalTo(@TSignalImageViewWidth);
        make.height.equalTo(@TSignalImageViewWidth);
    }];
    [self.timeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.signalImageView.mas_right).offset(2.5);
        make.centerY.equalTo(self.mas_centerY);
        make.width.equalTo(@TTimeLableWidth);
        make.height.equalTo(@TTimeLableHeight);
    }];
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
        make.width.equalTo(@TTitleViewWidth);
        make.height.equalTo(@TTitleViewHeight);
    }];
    [self.toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(0);
        make.right.equalTo(self.mas_right).offset(0);
        make.width.equalTo(@TToolViewWidth);
        make.height.equalTo(self.mas_height);
    }];
    
    [self.buttonArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:TButtonWidht leadSpacing:0 tailSpacing:20];
    [self.buttonArray mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toolView.mas_top).offset(topOffset);
        make.height.equalTo(@TButtonWidht);
    }];
}

- (void)refreshTitleView {
    [self setDefaultButtons];
    RoomMember *curMember = [ClassroomService sharedService].currentRoom.currentMember;
    BOOL cameraAvailable =  [self isCameraAvailable];
    BOOL microphoneAvailable =  [self isMicrophoneAvailable];
    switch (curMember.role) {
        case RoleAssistant:
        case RoleTeacher:
        case RoleStudent:
            if (cameraAvailable) {
                self.cameraBtn.selected = !curMember.cameraEnable;
            }else {
                self.cameraBtn.selected = YES;
            }
            if (microphoneAvailable) {
                self.microphoneBtn.selected = !curMember.microphoneEnable;
            }else {
                self.microphoneBtn.selected = YES;
            }
            
            break;
        case RoleAudience:
            self.switchCameraBtn.enabled = NO;
            self.microphoneBtn.enabled = NO;
            self.cameraBtn.enabled = NO;
            [self.switchCameraBtn setBackgroundImage:[UIImage imageNamed:@"switchcamera_disable"]  forState:UIControlStateNormal];
            [self.microphoneBtn setBackgroundImage:[UIImage imageNamed:@"speakerphone_disable"]  forState:UIControlStateNormal];
            [self.cameraBtn setBackgroundImage:[UIImage imageNamed:@"tcamera_disable"]  forState:UIControlStateNormal];
            break;
    }
    
}

- (void)timeFunction:(NSTimer *)timer
{
    self.timeLable.text = [self formatJoinTime];
}

- (void)stopDurationTimer {
    [self.timeTimer setFireDate:[NSDate distantFuture]];
    if (self.timeTimer.valid) {
        [self.timeTimer invalidate];
        self.timeTimer = nil;
    }
}

- (void)tapEvent:(UIButton *)btn {
    BOOL cameraAvailable =  [self isCameraAvailable];
    BOOL microphoneAvailable =  [self isMicrophoneAvailable];
    if (btn.tag == ClassroomTitleViewActionTagCamera &&!cameraAvailable) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"cameraAvailable", @"SealClass", nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"SealClass", nil) otherButtonTitles:nil];
        [alertView show];
        return;
    }
    if (btn.tag == ClassroomTitleViewActionTagMicrophone &&!microphoneAvailable) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"microphoneAvailable", @"SealClass", nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"SealClass", nil) otherButtonTitles:nil];
        [alertView show];
        return;
    }
    btn.selected = !btn.selected;
    if(self.delegate && [self.delegate respondsToSelector:@selector(classroomTitleView:didTapAtTag:)]) {
        [self.delegate classroomTitleView:btn didTapAtTag:btn.tag];
    }
}

- (void)setDefaultButtons {
    self.buttonImageArray = @[@"switchcamera", @"speakerphone", @"tcamera", @"quiet", @"hangup"];
    self.buttonHighlightedImageArray = @[@"switchcamera_selected", @"speakerphone_selected", @"tcamera_selected", @"quiet_selected", @"hangup_selected"];
    self.buttonCloseImageArray = @[@"switchcamera_close", @"speakerphone_close", @"tcamera_close", @"quiet_close", @"hangup"];
    for(int i = 0; i < self.buttonArray.count; i++) {
        UIButton *button = [self.buttonArray objectAtIndex:i];
        button.enabled = YES;
        [button setBackgroundImage:[UIImage imageNamed:[self.buttonImageArray objectAtIndex:i]] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:[self.buttonCloseImageArray objectAtIndex:i]]  forState:UIControlStateSelected];
        [button setBackgroundImage:[UIImage imageNamed:[self.buttonHighlightedImageArray objectAtIndex:i]] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage imageNamed:[self.buttonCloseImageArray objectAtIndex:i]] forState:UIControlStateSelected|UIControlStateHighlighted];
        
    }
}

- (BOOL)isCameraAvailable{
    __block BOOL canCamera = NO;
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        canCamera = NO;
    }else{
        canCamera = YES;
    }
    return canCamera;
}

-(BOOL)isMicrophoneAvailable
{
    __block BOOL canRecord = NO;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                canRecord = YES;
            }
            else {
                canRecord = NO;
            }
        }];
    }
    return canRecord;
}

- (NSString *)formatJoinTime {
    NSInteger durationInteger = self.duration ++;
    NSInteger durationS = durationInteger % 60;
    NSInteger durationM = ((durationInteger - durationS) / 60) % 60;
    NSInteger durationH = (durationInteger - durationS - 60 * durationM) / 3600;
    NSMutableArray * durationArr = [NSMutableArray new];
    [durationArr addObject:[NSString stringWithFormat:@"%02ld", durationH]];
    [durationArr addObject:[NSString stringWithFormat:@"%02ld", durationM]];
    [durationArr addObject:[NSString stringWithFormat:@"%02ld", durationS]];
    return [durationArr componentsJoinedByString:@":"];
}

- (UIImageView *)signalImageView {
    if(!_signalImageView) {
        _signalImageView = [[UIImageView alloc] init];
        _signalImageView.image = [UIImage imageNamed:@"signal_1"];
        _signalImageView.hidden = YES;
    }
    return _signalImageView;
}

- (UILabel *)timeLable {
    if(!_timeLable) {
        _timeLable = [[UILabel alloc] init];
        _timeLable.font = [UIFont systemFontOfSize:10];
        _timeLable.textColor = [UIColor colorWithHexString:@"FFFFFF" alpha:1];
    }
    return _timeLable;
}

- (UILabel *)titleLable {
    if(!_titleLable) {
        _titleLable = [[UILabel alloc] init];
        _titleLable.font = [UIFont systemFontOfSize:17];
        _titleLable.textColor = [UIColor colorWithHexString:@"FFFFFF" alpha:1];
        _titleLable.text = [ClassroomService sharedService].currentRoom.roomId ? [ClassroomService sharedService].currentRoom.roomId : @"" ;
    }
    return _titleLable;
}

- (UIView *)toolView {
    if(!_toolView) {
        _toolView = [[UIView alloc] init];
    }
    return _toolView;
}

- (UIButton *)switchCameraBtn {
    if(!_switchCameraBtn) {
        _switchCameraBtn = [[UIButton alloc] init];
        _switchCameraBtn.enabled = YES;
        _switchCameraBtn.tag = ClassroomTitleViewActionTagSwitchCamera;
        [_switchCameraBtn addTarget:self action:@selector(tapEvent:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _switchCameraBtn;
}

- (UIButton *)microphoneBtn {
    if(!_microphoneBtn) {
        _microphoneBtn = [[UIButton alloc] init];
        _microphoneBtn.enabled = YES;
        _microphoneBtn.tag =  ClassroomTitleViewActionTagMicrophone;
        [_microphoneBtn addTarget:self action:@selector(tapEvent:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _microphoneBtn;
}

- (UIButton *)cameraBtn {
    if(!_cameraBtn) {
        _cameraBtn = [[UIButton alloc] init];
        _cameraBtn.enabled = YES;
        _cameraBtn.tag =  ClassroomTitleViewActionTagCamera;
        [_cameraBtn addTarget:self action:@selector(tapEvent:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _cameraBtn;
}

- (UIButton *)muteBtn {
    if(!_muteBtn) {
        _muteBtn = [[UIButton alloc] init];
        _muteBtn.enabled = YES;
        _muteBtn.tag =  ClassroomTitleViewActionTagMute;
        [_muteBtn addTarget:self action:@selector(tapEvent:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _muteBtn;
}

- (UIButton *)hangupBtn {
    if(!_hangupBtn) {
        _hangupBtn = [[UIButton alloc] init];
        _hangupBtn.enabled = YES;
        _hangupBtn.tag =  ClassroomTitleViewActionTagHangup;
        [_hangupBtn addTarget:self action:@selector(tapEvent:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _hangupBtn;
}

- (NSMutableArray *)buttonArray {
    if (!_buttonArray) {
        _buttonArray = [[NSMutableArray alloc] init];
    }
    return _buttonArray;
}

- (NSTimer *)timeTimer {
    if (_timeTimer == nil) {
        
        _timeTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                      target:self
                                                    selector:@selector(timeFunction:)
                                                    userInfo:nil
                                                     repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timeTimer forMode:NSRunLoopCommonModes];
    }
    
    return _timeTimer;
}

@end
