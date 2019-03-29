//
//  RolePortraitView.m
//  SealClass
//
//  Created by 张改红 on 2019/3/15.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "RolePortraitView.h"
#import "RoomMember.h"
@interface RolePortraitView()
@property (nonatomic, strong) UILabel *nameLabel;
@end
@implementation RolePortraitView
- (instancetype)init{
    if (self = [super init]) {
        [self addSubview:self.nameLabel];
    }
    return self;
}

- (void)addHeaderBackground:(RoomMember *)member{
    [self.layer addSublayer:[self getRoleHeaderGradientLayer:member]];
    [self addSubview:self.nameLabel];
    self.nameLabel.text = [self setLabelWithName:member.name];
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
     

- (CAGradientLayer *)getRoleHeaderGradientLayer:(RoomMember *)member{
    CAGradientLayer *gradientLayer;
    switch (member.role) {
        case RoleAssistant:
            gradientLayer = [self createGradientLayerWithColors:@[(__bridge id)[UIColor colorWithHexString:@"FCCF31" alpha:1].CGColor,(__bridge id)[UIColor colorWithHexString:@"F56352" alpha:1].CGColor]];
            break;
        case RoleTeacher:
            gradientLayer = [self createGradientLayerWithColors:@[(__bridge id)[UIColor colorWithHexString:@"FBA276" alpha:1].CGColor,(__bridge id)[UIColor colorWithHexString:@"EB5756" alpha:1].CGColor]];
            break;
        case RoleStudent:
            gradientLayer = [self createGradientLayerWithColors:@[(__bridge id)[UIColor colorWithHexString:@"0ABFDC" alpha:1].CGColor,(__bridge id)[UIColor colorWithHexString:@"048BB7" alpha:1].CGColor]];
            break;
        case RoleAudience:
            gradientLayer = [self createGradientLayerWithColors:@[(__bridge id)[UIColor colorWithHexString:@"B9D5DC" alpha:1].CGColor,(__bridge id)[UIColor colorWithHexString:@"83ABB6" alpha:1].CGColor]];
            break;
        default:
            gradientLayer = [self createGradientLayerWithColors:@[(__bridge id)[UIColor lightGrayColor].CGColor,(__bridge id)[UIColor grayColor].CGColor]];
            break;
    }
    return gradientLayer;
}

- (CAGradientLayer *)createGradientLayerWithColors:(NSArray *)colors {
    CAGradientLayer * gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = colors;
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    gradientLayer.frame = CGRectMake(0, 0, 40, 40);
    return gradientLayer;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _nameLabel.layer.masksToBounds = YES;
        _nameLabel.layer.cornerRadius = 20;
        _nameLabel.font = [UIFont systemFontOfSize:18];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = [UIColor colorWithHexString:@"FFFFFF" alpha:1];
    }
    return _nameLabel;
}
@end
