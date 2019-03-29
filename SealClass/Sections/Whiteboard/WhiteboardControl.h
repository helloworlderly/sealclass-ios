//
//  WhiteboardControl.h
//  SealClass
//
//  Created by Zhaoqianyu on 2019/3/12.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoomMember.h"

@protocol WhiteboardControlDelegate<NSObject>
- (void)didTurnPage:(NSInteger)pageNum;
@end

NS_ASSUME_NONNULL_BEGIN

@interface WhiteboardControl : NSObject

@property(nonatomic, copy, readonly) NSString *currentWhiteboardId;
@property(nonatomic, copy, readonly) NSString *currentWhiteboardURL;
@property(nonatomic, assign, readonly) BOOL wBoardDisplayed;

- (instancetype)init __attribute__((unavailable("init not available, call initWithDelegate instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call initWithDelegate instead")));

- (instancetype)initWithDelegate:(id<WhiteboardControlDelegate>)delegate;
- (void)loadWBoardWith:(NSString *)wBoardID
             wBoardURL:(NSString *)wBoardURL
             superView:(UIView *)superView
                 frame:(CGRect)frame;
- (void)hideBoard;
- (void)destroyBoard;
- (void)turnPage:(NSInteger)pageNum;
- (void)setWBoardFrame:(CGRect)newFrame;
- (void)moveWBoard:(CGFloat)offset;
- (void)didChangeRole:(Role)role;

@end

NS_ASSUME_NONNULL_END
