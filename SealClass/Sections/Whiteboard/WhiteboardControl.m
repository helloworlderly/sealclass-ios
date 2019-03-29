//
//  WhiteboardControl.m
//  SealClass
//
//  Created by Zhaoqianyu on 2019/3/12.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "WhiteboardControl.h"
#import "WhiteboardView.h"


@interface WhiteboardControl()<WhiteboardViewDelegate>
@property(nonatomic, copy, readwrite) NSString *currentWhiteboardId;
@property(nonatomic, copy, readwrite) NSString *currentWhiteboardURL;
@property(nonatomic, strong) WhiteboardView *wbView;
@property(nonatomic, weak) id<WhiteboardControlDelegate> delegate;
@end

@implementation WhiteboardControl

- (instancetype)initWithDelegate:(id<WhiteboardControlDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)loadWBoardWith:(NSString *)wBoardID
             wBoardURL:(NSString *)wBoardURL
             superView:(UIView *)superView
                 frame:(CGRect)frame {
    self.currentWhiteboardId = wBoardID;
    self.currentWhiteboardURL = wBoardURL;
    self.wbView.currentFrame = frame;
    self.wbView.hidden = NO;
    if (self.wbView.superview != superView) {
        [superView addSubview:self.wbView];
    }
    [self.wbView reloadWithURL:[NSURL URLWithString:wBoardURL]];
}

- (void)hideBoard {
    self.wbView.hidden = YES;
}

- (void)destroyBoard {
    [self.wbView destroy];
}

- (void)turnPage:(NSInteger)pageNum {
    
}

- (void)setWBoardFrame:(CGRect)newFrame {
    self.wbView.currentFrame = newFrame;
}

- (void)moveWBoard:(CGFloat)offset {
    CGRect newFrame = CGRectMake(self.wbView.currentFrame.origin.x+offset, self.wbView.currentFrame.origin.y, self.wbView.currentFrame.size.width, self.wbView.currentFrame.size.height);
    self.wbView.currentFrame = newFrame;
}

- (void)didChangeRole:(Role)role {
    NSString * jsFunc = [NSString stringWithFormat:@"changeRole(%@, '%@');", @(role), self.currentWhiteboardId];
    [self.wbView evaluateJavaScript:jsFunc completionHandler:nil];
}

#pragma mark - WhiteboardViewDelegate

- (void)didTurnPage:(NSInteger)pageNum {
    
}

#pragma mark - Getters & setters

- (WhiteboardView *)wbView {
    if(!_wbView) {
        _wbView = [[WhiteboardView alloc] initWithDelegate:self];
    }
    return _wbView;
}

- (BOOL)wBoardDisplayed {
    return self.wbView.superview && !self.wbView.hidden;
}

@end
