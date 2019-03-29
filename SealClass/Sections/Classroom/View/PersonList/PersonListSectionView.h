//
//  PersonListSectionView.h
//  SealClass
//
//  Created by liyan on 2019/3/4.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomMember.h"

NS_ASSUME_NONNULL_BEGIN

@class PersonListSectionView;
@protocol PersonListSectionViewDelegate <NSObject>

- (void)didTapPersonListSectionView:(NSInteger)sectionTag;
- (void)didTapApplySpearker:(UIButton *)applyButton;

@end

@interface PersonListSectionView : UIView

@property (nonatomic, weak) id<PersonListSectionViewDelegate> delegate;

- (void)setModel:(RoomMember *)member applySpeaking:(BOOL)applySpeaking;

@end

NS_ASSUME_NONNULL_END
