//
//  ClassroomTitleView.h
//  SealClass
//
//  Created by Sin on 2019/2/28.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ClassroomTitleViewActionTagSwitchCamera,
    ClassroomTitleViewActionTagMicrophone,
    ClassroomTitleViewActionTagCamera,
    ClassroomTitleViewActionTagMute,
    ClassroomTitleViewActionTagHangup,
} ClassroomTitleViewActionTag;

@class ClassroomTitleView;
@protocol ClassroomTitleViewDelegate <NSObject>

- (void)classroomTitleView:(UIButton *)button didTapAtTag:(ClassroomTitleViewActionTag)tag;

@end

@interface ClassroomTitleView : UIView

@property (nonatomic, weak) id<ClassroomTitleViewDelegate> delegate;

@property (nonatomic, strong) UIButton *switchCameraBtn;

@property (nonatomic, strong) UIButton *microphoneBtn;

@property (nonatomic, strong) UIButton *cameraBtn;

@property (nonatomic, strong) UIButton *muteBtn;

@property (nonatomic, strong) UIButton *hangupBtn;

- (void)refreshTitleView;

- (void)stopDurationTimer;

@end

