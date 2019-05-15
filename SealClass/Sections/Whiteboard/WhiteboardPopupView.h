//
//  WhiteboardPopupView.h
//  SealClass
//
//  Created by Zhaoqianyu on 2019/3/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 点击选项回调 Block

 @param index 点击选项在 items 数组中的位置
 @param item 选项字段值
 */
typedef void(^SelectItemBlock)(NSInteger index, NSString *item);

@interface WhiteboardPopupView : UIView

/**
 创建一个带尖角的选项列表视图

 @param frame 位置坐标
 @param shapePointY 尖角的纵坐标
 @param items 可选项
 @param didSelectItem 点击选项的回调
 @return new object
 */
- (instancetype)initWithFrame:(CGRect)frame
                  shapePointY:(CGFloat)shapePointY
                        items:(NSArray<NSString *> *)items
                       inView:(UIView *)superView
                didSelectItem:(SelectItemBlock)didSelectItem;

- (void)destroy;

@end

NS_ASSUME_NONNULL_END
