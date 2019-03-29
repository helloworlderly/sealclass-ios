//
//  LoginViewController.m
//  SealClass
//
//  Created by LiFei on 2019/2/26.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "LoginViewController.h"
#import "ClassroomViewController.h"
#import <RongIMLib/RongIMLib.h>
#import "RTCService.h"
#import "SelectionButton.h"
#import "Masonry.h"
#import "InputTextField.h"
#import "SettingViewController.h"
#import "LoginHelper.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "ClassroomService.h"
#import "NormalAlertView.h"
#define classIdTextFieldTag 3000
#define userNameTextFieldTag 3001
@interface LoginViewController ()<UITextFieldDelegate, ClassroomHelperDelegate>
@property (nonatomic, strong) UIButton *setButton;
@property (nonatomic, strong) UIView *logoView;
@property (nonatomic, strong) InputTextField *classIdTextField;
@property (nonatomic, strong) InputTextField *userNameTextField;
@property (nonatomic, strong) SelectionButton *openVisitorButton;
@property (nonatomic, strong) UIButton *joinClassButton;
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation LoginViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [self addSubViews];
    [self addGesture];
    [self registerNotification];
    [LoginHelper sharedInstance].delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self didResignFirstResponder];
}

#pragma mark - ClassroomHelperDelegate
- (void)classroomDidJoin:(Classroom *)classroom{
    if ([self.navigationController.topViewController isKindOfClass:[self class]]) {
        [self.hud hideAnimated:YES];
        [self pushToClassroom];
    }
}

- (void)classroomDidJoinFail{
    [self.hud hideAnimated:YES];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"LoginFail", @"SealClass", nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"SealClass", nil) otherButtonTitles:nil];
    [alertView show];
}

- (void)classroomDidOverMaxUserCount{
    [self.hud hideAnimated:YES];
    [NormalAlertView showAlertWithTitle:NSLocalizedStringFromTable(@"OverMaxMessage", @"SealClass", nil) leftTitle:NSLocalizedStringFromTable(@"Cancel", @"SealClass", nil) rightTitle:NSLocalizedStringFromTable(@"OK", @"SealClass", nil) cancel:^{

    } confirm:^{
        [self login:YES];
    }];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    InputTextField *field = (InputTextField *)textField;
    [field setBorderState:(InputTextFieldBorderStateEditing)];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    InputTextField *field = (InputTextField *)textField;
    if (textField.text.length > 0) {
        switch (field.tag) {
            case classIdTextFieldTag:
                [self checkClassIdValidity];
                break;
            case userNameTextFieldTag:
                [self checkUserNameValidity];
                break;
            default:
                break;
        }
    }else{
        [field setBorderState:(InputTextFieldBorderStateNormal)];
    }
    [self enableJoinClassButton];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];//取消第一响应者
    return YES;
}

#pragma mark - Notification action
- (void)keyboardWillShow:(NSNotification*)notification {
    CGRect keyboardBounds = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:0.5 animations:^{
        [UIView setAnimationCurve:curve];
        CGRect originalFrame = [UIScreen mainScreen].bounds;
        if([self.classIdTextField isFirstResponder] && CGRectGetMaxY(self.classIdTextField.frame) > keyboardBounds.origin.y){
            originalFrame.origin.y = originalFrame.origin.y-(CGRectGetMaxY(self.classIdTextField.frame)-keyboardBounds.origin.y);
        }else if([self.userNameTextField isFirstResponder] && CGRectGetMaxY(self.userNameTextField.frame) > keyboardBounds.origin.y){
            originalFrame.origin.y = originalFrame.origin.y-(CGRectGetMaxY(self.userNameTextField.frame)-keyboardBounds.origin.y);
        }
        self.view.frame = originalFrame;
        [UIView commitAnimations];
    }];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [UIView animateWithDuration:0.5 animations:^{
        [UIView setAnimationCurve:0];
        CGRect originalFrame = self.view.frame;
        originalFrame.origin.y = 0;
        self.view.frame = originalFrame;
        [UIView commitAnimations];
    }];
}

#pragma mark - Target action
- (void)onJoinClass:(id)sender {
    [self login:self.openVisitorButton.selected];
}

- (void)onTapSetButton{
    SettingViewController *settingVC = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
}

#pragma mark - Helper
- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)pushToClassroom {
    ClassroomViewController *vc = [[ClassroomViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)checkClassIdValidity{
    if (self.classIdTextField.text.length > 40 || ![self isTextValidity:self.classIdTextField.text enableChinese:NO]) {
        self.classIdTextField.warnLabel.text = NSLocalizedStringFromTable(@"ClassIdWarn", @"SealClass", nil);
        self.classIdTextField.warnLabel.hidden = NO;
        [self.classIdTextField setBorderState:InputTextFieldBorderStateError];
    }else{
        self.classIdTextField.warnLabel.hidden = YES;
        [self.classIdTextField setBorderState:InputTextFieldBorderStateNormal];
    }
}

- (void)checkUserNameValidity{
    if (self.userNameTextField.text.length > 10 || ![self isTextValidity:self.userNameTextField.text enableChinese:YES]) {
        self.userNameTextField.warnLabel.text = NSLocalizedStringFromTable(@"UserNameWarn", @"SealClass", nil);
        self.userNameTextField.warnLabel.hidden = NO;
        [self.userNameTextField setBorderState:InputTextFieldBorderStateError];
    }else{
        self.userNameTextField.warnLabel.hidden = YES;
        [self.userNameTextField setBorderState:InputTextFieldBorderStateNormal];
    }
}

- (BOOL)isTextValidity:(NSString *)text enableChinese:(BOOL)enableChinese{
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *regex =@"^[a-zA-Z0-9]+$";
    if (enableChinese) {
        regex =@"^[\u4e00-\u9fa5a-zA-Z0-9]+$";
    }
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:text]) {
        return YES;
    }
    return NO;
}

- (void)enableJoinClassButton{
    if (self.userNameTextField.text.length > 0 && self.classIdTextField.text.length > 0 && self.classIdTextField.warnLabel.hidden && self.userNameTextField.warnLabel.hidden) {
        self.joinClassButton.enabled = YES;
        self.joinClassButton.alpha = 1;
    }else{
        self.joinClassButton.enabled = NO;
        self.joinClassButton.alpha = 0.5;
    }
}

- (void)didResignFirstResponder{
    if ([self.classIdTextField isFirstResponder]) {
        [self.classIdTextField resignFirstResponder];
    }else if ([self.userNameTextField isFirstResponder]){
        [self.userNameTextField resignFirstResponder];
    }
}

- (void)login:(BOOL)isAudience{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *roomId = [self.classIdTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *userName = [self.userNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [[LoginHelper sharedInstance] login:roomId user:userName isAudience:isAudience];
}

#pragma mark - SubViews
- (void)addSubViews{
    [self.view addSubview:self.setButton];
    [self.view addSubview:self.logoView];
    [self.view addSubview:self.classIdTextField];
    [self.view addSubview:self.userNameTextField];
    [self.view addSubview:self.openVisitorButton];
    [self.view addSubview:self.joinClassButton];
    
    [self.setButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-35);
        make.top.equalTo(self.view).offset(24);
        make.height.width.offset(36);
    }];
    
    [self.logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(25);
        make.height.offset(101);
        make.width.offset(213);
        make.centerX.equalTo(self.view);
    }];
    
    [self.classIdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logoView.mas_bottom).offset(24);
        make.height.offset(40);
        make.width.offset(300);
        make.centerX.equalTo(self.view);
    }];
    
    [self.userNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.classIdTextField.mas_bottom).offset(20);
        make.height.offset(40);
        make.width.offset(300);
        make.centerX.equalTo(self.view);
    }];
    
    [self.openVisitorButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userNameTextField.mas_bottom).offset(20);
        make.height.offset(20);
        make.width.offset(100);
        make.left.equalTo(self.userNameTextField.mas_left).offset(20);
    }];
    
    [self.joinClassButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.openVisitorButton.mas_bottom).offset(20);
        make.height.offset(44);
        make.width.offset(300);
        make.centerX.equalTo(self.view);
    }];
    [self addLogoViewSubviews];
    [self.view layoutIfNeeded];
}

- (void)addLogoViewSubviews{
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_login"]];
    [self.logoView addSubview:logoImageView];
    UILabel *logoTitleLabel = [[UILabel alloc] init];
    logoTitleLabel.text = NSLocalizedStringFromTable(@"SealClass", @"SealClass", nil);
    logoTitleLabel.font = [UIFont systemFontOfSize:18];
    logoTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.logoView addSubview:logoTitleLabel];
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logoView).offset(0);
        make.height.offset(71);
        make.width.offset(71);
        make.centerX.equalTo(self.view);
    }];
    
    [logoTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(logoImageView.mas_bottom).offset(10);
        make.height.offset(20);
        make.width.offset(100);
        make.centerX.equalTo(self.view);
    }];
}

- (void)addGesture{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(didResignFirstResponder)];
    [self.view addGestureRecognizer:tap];
}
#pragma mark - Getters & setters
- (UIButton *)setButton{
    if (!_setButton) {
        _setButton = [[UIButton alloc] init];
        [_setButton setImage:[UIImage imageNamed:@"set"] forState:(UIControlStateNormal)];
        [_setButton addTarget:self action:@selector(onTapSetButton) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _setButton;
}

- (UIView *)logoView{
    if (!_logoView) {
        _logoView = [[UIView alloc] init];
    }
    return _logoView;
}

- (UITextField *)classIdTextField{
    if (!_classIdTextField) {
        _classIdTextField = [[InputTextField alloc] init];
        _classIdTextField.placeholder = NSLocalizedStringFromTable(@"ClassId", @"SealClass", nil);
        _classIdTextField.delegate = self;
        _classIdTextField.tag = classIdTextFieldTag;
    }
    return _classIdTextField;
}

- (UITextField *)userNameTextField{
    if (!_userNameTextField) {
        _userNameTextField = [[InputTextField alloc] init];
        _userNameTextField.placeholder = NSLocalizedStringFromTable(@"UserName", @"SealClass", nil);
        _userNameTextField.delegate = self;
        _userNameTextField.tag = userNameTextFieldTag;
    }
    return _userNameTextField;
}

- (SelectionButton *)openVisitorButton{
    if (!_openVisitorButton) {
        _openVisitorButton = [[SelectionButton alloc] init];
        [_openVisitorButton setTitle:NSLocalizedStringFromTable(@"OpenVisitor", @"SealClass", nil) forState:UIControlStateNormal];
        [_openVisitorButton setSelected:NO];
    }
    return _openVisitorButton;
}

- (UIButton *)joinClassButton{
    if (!_joinClassButton) {
        _joinClassButton = [[UIButton alloc] init];
        [_joinClassButton addTarget:self action:@selector(onJoinClass:) forControlEvents:(UIControlEventTouchUpInside)];
        [_joinClassButton setTitle:NSLocalizedStringFromTable(@"JoinClass", @"SealClass", nil) forState:(UIControlStateNormal)];
        _joinClassButton.backgroundColor = HEXCOLOR(0x0de098);
        _joinClassButton.layer.masksToBounds = YES;
        _joinClassButton.layer.cornerRadius = 22;
        CAGradientLayer *gradientLayer =  [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(0, 0, 200, 44);
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 0);
        gradientLayer.locations = @[@(0.5),@(1.0)];//渐变点
        UIColor *startColor = HEXCOLOR(0x02B9B7);
        UIColor *endColor = HEXCOLOR(0x0de098);
        [gradientLayer setColors:@[(id)(startColor.CGColor),(id)(endColor.CGColor)]];//渐变数组
        [_joinClassButton.layer addSublayer:gradientLayer];
        _joinClassButton.enabled = NO;
        _joinClassButton.alpha = 0.5;
    }
    return _joinClassButton;
}
@end
