//
//  PersonListSectionView.m
//  SealClass
//
//  Created by liyan on 2019/3/4.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "PersonListSectionView.h"
#import "Masonry.h"
#import "ClassroomService.h"

#define LeftMargin   20
#define NormalMargin   10
#define HeaderImageViewWidth   40
#define PortraitLableWidth 30
#define NameLableHeight   22.5
#define NameLableWidth   96
#define PersonRoleLableHeight   14
#define PersonRoleLableWidth   30
#define ApplyButtonHeight  30
#define ApplyButtonWidth 61


@interface PersonListSectionView()

@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *portraitLable;
@property (nonatomic, strong) UILabel *nameLable;
@property (nonatomic, strong) UILabel *personRoleLable;
@property (nonatomic, strong) UIButton *applySpeakerButton;
@property (nonatomic, strong) RoomMember *member;

@end

@implementation PersonListSectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
        [self addGestureRecognizer:gesture];
        [self addSubViews];
    }
    return self;
}

- (void)addSubViews {
    [self addSubview:self.headerImageView];
    [self addSubview:self.portraitLable];
    [self addSubview:self.nameLable];
    [self addSubview:self.personRoleLable];
    [self addSubview:self.applySpeakerButton];
    [self.headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(NormalMargin);
        make.left.equalTo(self.mas_left).offset(LeftMargin);
        make.width.equalTo(@HeaderImageViewWidth);
        make.height.equalTo(@HeaderImageViewWidth);
    }];
    [self.portraitLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.headerImageView.mas_centerY);
        make.centerX.equalTo(self.headerImageView.mas_centerX);
        make.width.equalTo(@PortraitLableWidth);
        make.height.equalTo(@PortraitLableWidth);
    }];
    
    [self.nameLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerImageView.mas_right).offset(NormalMargin);
        make.centerY.equalTo(self.headerImageView.mas_centerY);
        make.height.equalTo(@NameLableHeight);
        make.width.equalTo(@NameLableWidth);
    }];
    [self.personRoleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLable.mas_right).offset(NormalMargin);
        make.centerY.equalTo(self.headerImageView.mas_centerY);
        make.height.equalTo(@PersonRoleLableHeight);
        make.width.equalTo(@PersonRoleLableWidth);
    }];
    [self.applySpeakerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-6);
        make.centerY.equalTo(self.headerImageView.mas_centerY);
        make.height.equalTo(@ApplyButtonHeight);
        make.width.equalTo(@ApplyButtonWidth);
    }];
}

- (void)setModel:(RoomMember *)member applySpeaking:(BOOL)applySpeaking{
    if (!member) {
        return;
    }
    [self resetDefaultStyle];
    self.member = member;
    RoomMember *curMember = [ClassroomService sharedService].currentRoom.currentMember;
        if (curMember.role == RoleAudience && [member.userId isEqualToString:curMember.userId] && curMember != nil) {
            self.applySpeakerButton.hidden = NO;
            if (applySpeaking) {
                self.applySpeakerButton.enabled = NO;
                [self.applySpeakerButton setTitle:NSLocalizedStringFromTable(@"ApplySpeakering", @"SealClass", nil) forState:UIControlStateNormal];
            }
        }
    
    CAGradientLayer *gradientLayer;
    switch (member.role) {
        case RoleAssistant:
            gradientLayer = [self createGradientLayerWithColors:@[(__bridge id)[UIColor colorWithHexString:@"FCCF31" alpha:1].CGColor,(__bridge id)[UIColor colorWithHexString:@"F56352" alpha:1].CGColor]];
            [self.headerImageView.layer addSublayer:gradientLayer];
            self.personRoleLable.backgroundColor = [UIColor colorWithHexString:@"F5A623" alpha:1];
            self.personRoleLable.text = NSLocalizedStringFromTable(@"RoleAssitant", @"SealClass", nil);
            break;
        case RoleTeacher:
            gradientLayer = [self createGradientLayerWithColors:@[(__bridge id)[UIColor colorWithHexString:@"FBA276" alpha:1].CGColor,(__bridge id)[UIColor colorWithHexString:@"EB5756" alpha:1].CGColor]];
            [self.headerImageView.layer addSublayer:gradientLayer];
            self.personRoleLable.backgroundColor = [UIColor colorWithHexString:@"FF5500" alpha:1];
            self.personRoleLable.text = NSLocalizedStringFromTable(@"RoleTeacher", @"SealClass", nil);
            break;
        case RoleStudent:
            gradientLayer = [self createGradientLayerWithColors:@[(__bridge id)[UIColor colorWithHexString:@"0ABFDC" alpha:1].CGColor,(__bridge id)[UIColor colorWithHexString:@"048BB7" alpha:1].CGColor]];
            [self.headerImageView.layer addSublayer:gradientLayer];
            self.personRoleLable.hidden = YES;
            break;
        case RoleAudience:
            gradientLayer = [self createGradientLayerWithColors:@[(__bridge id)[UIColor colorWithHexString:@"B9D5DC" alpha:1].CGColor,(__bridge id)[UIColor colorWithHexString:@"83ABB6" alpha:1].CGColor]];
            [self.headerImageView.layer addSublayer:gradientLayer];
            self.personRoleLable.hidden = YES;
            
            break;
            
        default:
            break;
    }
    [self remakeNameLable:member];
    self.portraitLable.text = [self setLabelWithName:member.name];
}

- (void)resetDefaultStyle {
    self.personRoleLable.hidden = NO;
    self.personRoleLable.text = nil;
    self.applySpeakerButton.hidden = YES;
    self.applySpeakerButton.enabled = YES;
}

- (void)remakeNameLable:(RoomMember *)member {
    NSString * nameTxt = [[NSString alloc] init];
    nameTxt =  member.name.length > 3 ? [NSString stringWithFormat:@"%@...",[member.name substringToIndex:3]] : member.name;
    self.nameLable.text = nameTxt;
    CGSize textSize = [nameTxt sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    [self.nameLable mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo([NSNumber numberWithFloat:(ceil(textSize.width)+10)]);
    }];
}

- (void)tapHandler:(UITapGestureRecognizer *)gestureRecognizer {
    RoomMember *currentMember = [ClassroomService sharedService].currentRoom.currentMember;
    if ([currentMember.userId isEqualToString:self.member.userId] || currentMember == nil) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(didTapPersonListSectionView:)]) {
        [self.delegate didTapPersonListSectionView:self.tag];
    }
}

- (void)didTapApplySpearker:(UIButton *)applyButton {
    applyButton.enabled = NO;
    [self.applySpeakerButton setTitle:NSLocalizedStringFromTable(@"ApplySpeakering", @"SealClass", nil) forState:UIControlStateNormal];
    if ([self.delegate respondsToSelector:@selector(didTapApplySpearker:)]) {
        [self.delegate didTapApplySpearker:applyButton];
    }
}

- (CAGradientLayer *)createGradientLayerWithColors:(NSArray *)colors {
    CAGradientLayer * gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = colors;
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    gradientLayer.frame = CGRectMake(0, 0, HeaderImageViewWidth, HeaderImageViewWidth);
    return gradientLayer;
}

- (NSString *)setLabelWithName:(NSString *)name {
    NSString *firstLetter = nil;
    if (name.length > 0) {
        firstLetter = [name substringFromIndex:name.length - 1];
    } else {
        firstLetter = @"#";
    }
    return firstLetter;
}


- (UIImageView *)headerImageView {
    if(!_headerImageView) {
        _headerImageView = [[UIImageView alloc] init];
        _headerImageView.layer.cornerRadius = HeaderImageViewWidth / 2;
        _headerImageView.layer.masksToBounds = YES;
    }
    return _headerImageView;
}

- (UILabel *)portraitLable {
    if(!_portraitLable) {
        _portraitLable = [[UILabel alloc] init];
        _portraitLable.font = [UIFont systemFontOfSize:18];
        _portraitLable.textAlignment = NSTextAlignmentCenter;
        _portraitLable.textColor = [UIColor colorWithHexString:@"FFFFFF" alpha:1];
    }
    return _portraitLable;
}

- (UILabel *)nameLable {
    if(!_nameLable) {
        _nameLable = [[UILabel alloc] init];
        _nameLable.font = [UIFont systemFontOfSize:16];
        _nameLable.textColor = [UIColor colorWithHexString:@"FFFFFF" alpha:1];
    }
    return _nameLable;
}

- (UILabel *)personRoleLable {
    if(!_personRoleLable) {
        _personRoleLable = [[UILabel alloc] init];
        _personRoleLable.font = [UIFont systemFontOfSize:10];
        _personRoleLable.textColor = [UIColor colorWithHexString:@"FFFFFF" alpha:1];
        _personRoleLable.textAlignment = NSTextAlignmentCenter;
        _personRoleLable.layer.cornerRadius = 4;
        _personRoleLable.layer.masksToBounds = YES;
        
    }
    return _personRoleLable;
}

- (UIButton *)applySpeakerButton {
    if(!_applySpeakerButton) {
        _applySpeakerButton = [[UIButton alloc] init];
        _applySpeakerButton.backgroundColor =  [UIColor clearColor];
        [_applySpeakerButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_applySpeakerButton setTitleColor:[UIColor colorWithHexString:@"21C194" alpha:1] forState:UIControlStateNormal];
        [_applySpeakerButton setTitle:NSLocalizedStringFromTable(@"ApplySpeaker", @"SealClass", nil) forState:UIControlStateNormal];
        _applySpeakerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _applySpeakerButton.layer.cornerRadius = 15;
        _applySpeakerButton.layer.masksToBounds = YES;
        [_applySpeakerButton.layer setBorderColor:[UIColor colorWithHexString:@"21C194" alpha:1].CGColor];
        [_applySpeakerButton.layer setBorderWidth:1.0];
        [_applySpeakerButton addTarget:self action:@selector(didTapApplySpearker:) forControlEvents:UIControlEventTouchUpInside];
        _applySpeakerButton.hidden = YES;
        _applySpeakerButton.enabled = YES;
    }
    return _applySpeakerButton;
}

@end

