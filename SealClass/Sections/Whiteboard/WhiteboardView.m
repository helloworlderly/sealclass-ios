//
//  WhiteboardView.m
//  SealClass
//
//  Created by Zhaoqianyu on 2019/3/6.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "WhiteboardView.h"
#import <WebKit/WebKit.h>
#import <Masonry/Masonry.h>
#import "ZoomControl.h"

@interface WhiteboardView()<WKUIDelegate, WKNavigationDelegate,ZoomControlDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) ZoomControl *zoomControl;
@property (nonatomic, assign) BOOL isFullScreenMode;
@property (nonatomic, weak) id<WhiteboardViewDelegate> delegate;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIView *backView;
@end

@implementation WhiteboardView

- (instancetype)initWithDelegate:(id<WhiteboardViewDelegate>)delegate {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.delegate = delegate;
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.webView];
        [self addSubview:self.backView];
        [self addSubview:self.zoomControl];
        [self addSubview:self.indicatorView];
        
        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        [self.zoomControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self);
            make.right.mas_equalTo(self);
            make.width.height.mas_equalTo(100);
        }];
        [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(40);
            make.center.mas_equalTo(self);
        }];
    }
    return self;
}

- (void)reloadWithURL:(NSURL *)url {
    self.backView.hidden = NO;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [self.zoomControl resetDefaultScale];
}

- (void)destroy {
    [self.webView stopLoading];
    [self removeFromSuperview];
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id result, NSError * _Nullable error))completionHandler {
    [self.webView evaluateJavaScript:javaScriptString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        completionHandler ? completionHandler(result, error) : nil;
    }];
    
}

- (void)setCurrentFrame:(CGRect)currentFrame {
    _currentFrame = currentFrame;
    if (!self.isFullScreenMode) {
        self.frame = currentFrame;
    }
}

#pragma mark - ZoomControlDelegate
- (void)zoomControlDelegate:(CGFloat)scale{
    self.clipsToBounds = YES;
    CGSize baseSize = self.frame.size;
    baseSize.height *= scale;
    baseSize.width *= scale;
    CGPoint center = self.webView.center;
    CGRect frame = self.frame;
    frame.size = baseSize;
    self.webView.frame = frame;
    self.webView.center = center;
    if (self.delegate && [self.delegate respondsToSelector:@selector(whiteboardViewDidChangeZoomScale:)]) {
        [self.delegate whiteboardViewDidChangeZoomScale:scale];
    }
}

- (void)fullScreenDidUpdate:(BOOL)isFull{
    self.isFullScreenMode = isFull;
    UIView *superView = self.superview;
    if (self.isFullScreenMode) {
        [superView bringSubviewToFront:self];
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = CGRectMake(0, 0, UIScreenWidth, UIScreenHeight);
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = self.currentFrame;
        }];
    }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, card);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self showIndicatorView:YES];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self showIndicatorView:NO];
    NSLog(@"White board web view network error: %@", error);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self showIndicatorView:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.backView.hidden = YES;
    });
}

- (void)showIndicatorView:(BOOL)show{
    [self.indicatorView stopAnimating];
    self.indicatorView.hidden = YES;
    if (show) {
        self.indicatorView.hidden = NO;
        [self.indicatorView startAnimating];
    }
}
#pragma mark - JS Call back

- (void)pageDidTurn:(NSInteger)pageNum {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTurnPage:)]) {
        [self.delegate didTurnPage:pageNum];
    }
}

#pragma mark - Setter & getter
- (WKWebView *)webView{
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        config.preferences = [WKPreferences new];
        config.preferences.minimumFontSize = 10;
        config.preferences.javaScriptEnabled = YES;
        config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero];
        _webView.scrollView.scrollEnabled = NO;
        _webView.scrollView.alwaysBounceVertical = NO;
        _webView.scrollView.alwaysBounceHorizontal = NO;
        _webView.scrollView.bounces = false;
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        _webView.scrollView.bouncesZoom = NO;
        _webView.backgroundColor = [UIColor clearColor];
    }
    return _webView;
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.hidden = YES;
    }
    return _backView;
}

- (ZoomControl *)zoomControl{
    if (!_zoomControl) {
        _zoomControl = [[ZoomControl alloc] init];
        _zoomControl.delegate = self;
    }
    return _zoomControl;
}

- (UIActivityIndicatorView *)indicatorView{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _indicatorView;
}

@end
