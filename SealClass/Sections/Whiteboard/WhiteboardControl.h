//
//  WhiteboardControl.h
//  SealClass
//
//  Created by Zhaoqianyu on 2019/3/12.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoomMember.h"
#import "WhiteboardView.h"
@protocol WhiteboardControlDelegate<NSObject>
- (void)didTurnPage:(NSInteger)pageNum;
- (void)whiteboardViewDidChangeZoomScale:(float)scale;
@end

NS_ASSUME_NONNULL_BEGIN

@interface WhiteboardControl : NSObject

@property(nonatomic, copy, readonly) NSString *currentWhiteboardId;
@property(nonatomic, copy, readonly) NSString *currentWhiteboardURL;
@property(nonatomic, assign, readonly) BOOL wBoardDisplayed;
@property(nonatomic, strong) WhiteboardView *wbView;
- (instancetype)init __attribute__((unavailable("init not available, call initWithDelegate instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call initWithDelegate instead")));

- (instancetype)initWithDelegate:(id<WhiteboardControlDelegate>)delegate;
- (void)loadWBoardWith:(NSString *)wBoardID
             wBoardURL:(NSString *)wBoardURL
                 frame:(CGRect)frame;
- (void)hideBoard;
- (void)destroyBoard;
- (void)turnPage:(NSInteger)pageNum;
- (void)setWBoardFrame:(CGRect)newFrame;
- (void)moveWBoard:(CGFloat)offset;
- (void)didChangeRole:(Role)role;
- (void)moveToSuperView:(UIView *)superView;
@end

NS_ASSUME_NONNULL_END
