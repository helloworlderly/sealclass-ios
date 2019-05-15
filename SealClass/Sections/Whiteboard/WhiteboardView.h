//
//  WhiteboardView.h
//  SealClass
//
//  Created by Zhaoqianyu on 2019/3/6.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WhiteboardViewDelegate<NSObject>
- (void)didTurnPage:(NSInteger)pageNum;
- (void)whiteboardViewDidChangeZoomScale:(float)scale;
@end

@interface WhiteboardView : UIView

@property(nonatomic, assign, readwrite) CGRect currentFrame;

- (instancetype)init __attribute__((unavailable("init not available, call initWithDelegate instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call initWithDelegate instead")));
- (instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("initWithFrame not available, call initWithDelegate instead")));

- (instancetype)initWithDelegate:(id<WhiteboardViewDelegate>)delegate;
- (void)reloadWithURL:(NSURL *)url;
- (void)destroy;
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id result, NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
