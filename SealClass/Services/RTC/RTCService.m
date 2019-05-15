//
//  RTCService.m
//  SealClass
//
//  Created by LiFei on 2019/2/27.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RTCService.h"

#define SharedScreenStreamTag @"screenshare"

@interface RTCService ()<RongRTCAVInputStreamDelegate>
@property (nonatomic, strong) RongRTCRoom *rtcRoom;
@property (nonatomic, strong) RongRTCAVCapturer *capturer;
@property (nonatomic, strong) NSMutableDictionary *cachedVideoBufferDic;
@property (nonatomic, strong) UIImage *currentUserImage;
@property (nonatomic, assign) BOOL needRefreshCurrentUserImage;
@end

@implementation RTCService
+ (instancetype)sharedInstance {
    static RTCService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[self alloc] init];
        service.cachedVideoBufferDic = [NSMutableDictionary new];
        service.needRefreshCurrentUserImage = YES;
    });
    return service;
}

- (void)setRTCRoomDelegate:(id<RongRTCRoomDelegate>)delegate {
    if(!self.rtcRoom) {
        NSLog(@"尚未加入 rtc room，无法设置代理");
        return;
    }
    self.rtcRoom.delegate = delegate;
}

#pragma mark - 发布/订阅音视频流
- (void)joinRongRTCRoom:(NSString *)roomId success:(void (^)( RongRTCRoom  * _Nullable room))success error:(void (^)(RongRTCCode code))error {
    [[RongRTCEngine sharedEngine] joinRoom:roomId completion:^(RongRTCRoom * _Nullable room, RongRTCCode code) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(RongRTCCodeSuccess == code) {
                self.rtcRoom = room;
                if(success) {
                    success(room);
                }
            }else {
                if(error) {
                    error(code);
                }
            }
        });
    }];
}

- (void)leaveRongRTCRoom:(NSString*)roomId success:(void (^)(void))success error:(void (^)(RongRTCCode code))error {
    [[RongRTCEngine sharedEngine] leaveRoom:roomId completion:^(BOOL isSuccess, RongRTCCode code) {
        dispatch_async(dispatch_get_main_queue(), ^{
            SealClassLog(@"离开 RTCRoom ，code = %ld",(long)code);
            if(isSuccess || RongRTCCodeSuccess == code) {
                if(success) {
                    success();
                }
            }else {
                if(error) {
                    error(code);
                }
            }
        });
    }];
}

- (void)publishLocalUserDefaultAVStream {
    if(!self.rtcRoom) {
        NSLog(@"尚未加入 rtc room，不能发布音视频流");
        return;
    }
    [self.rtcRoom publishDefaultAVStream:^(BOOL isSuccess, RongRTCCode desc) {
        NSLog(@"当前用户发布音视频流 %@",@(desc));
    }];
}

- (void)unpublishLocalUserDefaultAVStream {
    if(!self.rtcRoom) {
        NSLog(@"尚未加入 rtc room，不能取消发布音视频流");
        return;
    }
    [self.rtcRoom unpublishDefaultAVStream:^(BOOL isSuccess, RongRTCCode desc) {
        NSLog(@"当前用户取消发送音视频流 %@",@(desc));
    }];
}

- (void)renderRemoteVideoOnView:(UIView *)view forUser:(NSString *)userId {
    if(!userId || !view) {
        NSLog(@"无法渲染视频：非法参数");
        return;
    }
    [self cancelRenderVideoInView:view];
    
    RTCService *service = self;
    for(RongRTCRemoteUser *remoteUser in service.rtcRoom.remoteUsers) {
        if([userId isEqualToString:remoteUser.userId]) {
            [self renderVideoOnView:view forRTCRemoteUser:remoteUser];
            [self subscribeRemoteUserAVStream:remoteUser];
            break;
        }
    }
}

- (void)renderUserSharedScreenOnView:(UIView *)view forUser:(NSString *)userId {
    [self cancelRenderVideoInView:view];
    for(RongRTCRemoteUser *remoteUser in self.rtcRoom.remoteUsers) {
        if([userId isEqualToString:remoteUser.userId]) {
            [self subscribeRemoteUserAVStream:remoteUser];
            for (RongRTCAVInputStream *stream in remoteUser.remoteAVStreams) {
                if (RTCMediaTypeVideo == stream.streamType && [stream.tag isEqualToString:SharedScreenStreamTag]) {
                    RongRTCRemoteVideoView *remoteView = [[RongRTCRemoteVideoView alloc] initWithFrame:view.bounds];
                    remoteView.backgroundColor = [UIColor colorWithHexString:@"3D4041" alpha:1];
                    [view insertSubview:remoteView atIndex:0];
                    [stream setVideoRender:remoteView];
                    return;
                }
            }
            break;
        }
    }
}

- (void)renderLocalVideoOnView:(UIView *)view cameraEnable:(BOOL)enable {
    if(!view) {
        NSLog(@"无法渲染视频：非法参数");
        return;
    }
    [self cancelRenderVideoInView:view];
    
    RongRTCLocalVideoView *localView = [[RongRTCLocalVideoView alloc] initWithFrame:view.bounds];
    localView.backgroundColor = [UIColor colorWithHexString:@"3D4041" alpha:1];
    localView.fillMode = RCVideoFillModeAspectFill;
    [[RongRTCAVCapturer sharedInstance] setVideoRender:localView];
    [view insertSubview:localView atIndex:0];
    
    self.captureParam.turnOnCamera = enable;
    [self.capturer setCaptureParam:self.captureParam];
    
    __weak typeof(self) ws = self;
    [self.capturer setVideoSendBufferCallback:^CMSampleBufferRef _Nullable(BOOL valid, CMSampleBufferRef  _Nullable sampleBuffer) {
        if(ws.needRefreshCurrentUserImage) {
            CVPixelBufferRef pixelBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer);
            ws.currentUserImage = [ws imageForPixelBufferRef:pixelBufferRef];
            ws.needRefreshCurrentUserImage = NO;
        }
        return sampleBuffer;
    }];
    [self.capturer startCapture];
}

- (BOOL)cancelRenderVideoInView:(UIView *)view {
    BOOL canceled = NO;
    UIView *renderedView = nil;
    for(UIView * v in view.subviews) {
        if([v isKindOfClass:[RongRTCLocalVideoView class]] || [v isKindOfClass:[RongRTCRemoteVideoView class]]) {
            renderedView = v;
            break;
        }
    }
    if(renderedView) {
        [renderedView removeFromSuperview];
        canceled = YES;
    }
    return canceled;
}

- (void)clipVideoInView:(UIView *)view scale:(CGFloat)scale {
    RongRTCVideoPreviewView *renderedView = nil;
    for(UIView * v in view.subviews) {
        if([v isKindOfClass:[RongRTCLocalVideoView class]] || [v isKindOfClass:[RongRTCRemoteVideoView class]]) {
            renderedView = (RongRTCVideoPreviewView *)v;
            break;
        }
    }
    if(!renderedView) {
        NSLog(@"未找到 RTC 视频渲染页面，无法裁剪");
        return;
    }
    view.clipsToBounds = YES;
    CGSize baseSize = view.frame.size;
    baseSize.height *= scale;
    baseSize.width *= scale;
    CGPoint center = renderedView.center;
    CGRect frame = renderedView.frame;
    frame.size = baseSize;
    renderedView.frame = frame;
    renderedView.center = center;
}


- (void)subscribeRemoteUserAVStream:(RongRTCRemoteUser *)remoteUser {
    if(!self.rtcRoom || remoteUser.remoteAVStreams.count <= 0) {
        NSLog(@"尚未加入 rtc room 或者远端用户资源不存在，不能订阅音视频流");
        NSLog(@"user:%@ streams:%@",remoteUser.userId,remoteUser.remoteAVStreams);
        return;
    }
    [self.rtcRoom subscribeAVStream:remoteUser.remoteAVStreams tinyStreams:nil completion:^(BOOL isSuccess, RongRTCCode desc) {
        NSLog(@"订阅流 %@ success:%@ code:%@",remoteUser.userId,@(isSuccess),@(desc));
    }];
}

- (void)unsubscribeRemoteUserAVStream:(RongRTCRemoteUser *)remoteUser {
    if(!self.rtcRoom) {
        NSLog(@"尚未加入 rtc room，不能取消订阅音视频流");
        return;
    }
    [self.rtcRoom unsubscribeAVStream:remoteUser.remoteAVStreams completion:^(BOOL isSuccess, RongRTCCode desc) {
        NSLog(@"取消订阅流 %@ success:%@ code:%@",remoteUser.userId,@(isSuccess),@(desc));
    }];
}

- (void)renderVideoOnView:(UIView *)view forRTCRemoteUser:(RongRTCRemoteUser *)remoteUser {
    if(remoteUser.remoteAVStreams.count <= 0) {
        NSLog(@"音视频流异常，无法渲染");
        return;
    }
    for(RongRTCAVInputStream *stream in remoteUser.remoteAVStreams) {
        if(RTCMediaTypeVideo == stream.streamType && ![stream.tag isEqualToString:SharedScreenStreamTag]) {
            RongRTCRemoteVideoView *remoteView = [[RongRTCRemoteVideoView alloc] initWithFrame:view.bounds];
            remoteView.backgroundColor = [UIColor colorWithHexString:@"3D4041" alpha:1];
            remoteView.frame = view.bounds;
            remoteView.fillMode = RCVideoFillModeAspectFill;
            stream.delegate = self;
            [view insertSubview:remoteView atIndex:0];
            [stream setVideoRender:remoteView];
            return;
        }
    }
}

#pragma mark - 顶部工具栏接口
- (void)setMicrophoneDisable:(BOOL)disable {
    [self.capturer setMicrophoneDisable:disable];
}

- (void)setCameraDisable:(BOOL)disable {
    [self.capturer setCameraDisable:disable];
}

- (void)switchCamera {
    [self.capturer switchCamera];
}

- (void)useSpeaker:(BOOL)useSpeaker {
    [self.capturer useSpeaker:useSpeaker];
}

- (void)stopCapture {
    [self.capturer stopCapture];
}

- (UIImage *)imageForCurrentUser {
    return [UIImage imageWithCGImage:self.currentUserImage.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationRight];
}

- (UIImage *)imageForOtherUser:(NSString *)userId {
    CVPixelBufferRef sampleBuffer = (__bridge CVPixelBufferRef)([self.cachedVideoBufferDic objectForKey:userId]);
    UIImage *image = [self imageForPixelBufferRef:sampleBuffer];
    return image;
}

- (void)refreshCurrentImage {
    self.needRefreshCurrentUserImage = YES;
}

-(void)willRenderCVPixelBufferRef:(CVPixelBufferRef)ref stream:(RongRTCAVInputStream *)stream {
    [self.cachedVideoBufferDic setValue:(__bridge id _Nullable)(ref) forKey:stream.userId];
}

- (UIImage *)imageForPixelBufferRef:(CVPixelBufferRef)sampleBuffer {
#define clamp(a) (a>255?255:(a<0?0:a))
    CVImageBufferRef imageBuffer = sampleBuffer;
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    uint8_t *yBuffer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    size_t yPitch = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    uint8_t *cbCrBuffer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
    size_t cbCrPitch = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 1);
    
    int bytesPerPixel = 4;
    uint8_t *rgbBuffer = malloc(width * height * bytesPerPixel);
    
    for(int y = 0; y < height; y++) {
        uint8_t *rgbBufferLine = &rgbBuffer[y * width * bytesPerPixel];
        uint8_t *yBufferLine = &yBuffer[y * yPitch];
        uint8_t *cbCrBufferLine = &cbCrBuffer[(y >> 1) * cbCrPitch];
        
        for(int x = 0; x < width; x++) {
            int16_t y = yBufferLine[x];
            int16_t cb = cbCrBufferLine[x & ~1] - 128;
            int16_t cr = cbCrBufferLine[x | 1] - 128;
            
            uint8_t *rgbOutput = &rgbBufferLine[x*bytesPerPixel];
            
            int16_t r = (int16_t)roundf( y + cr *  1.4 );
            int16_t g = (int16_t)roundf( y + cb * -0.343 + cr * -0.711 );
            int16_t b = (int16_t)roundf( y + cb *  1.765);
            
            rgbOutput[0] = 0xff;
            rgbOutput[1] = clamp(b);
            rgbOutput[2] = clamp(g);
            rgbOutput[3] = clamp(r);
        }
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbBuffer, width, height, 8, width * bytesPerPixel, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    //    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(quartzImage);
    free(rgbBuffer);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    return image;
}

#pragma mark - getter
- (RongRTCAVCapturer *)capturer {
    if(!_capturer) {
        _capturer = [RongRTCAVCapturer sharedInstance];
    }
    return _capturer;
}

- (RongRTCVideoCaptureParam *)captureParam {
    if(!_captureParam) {
        _captureParam = [[RongRTCVideoCaptureParam alloc] init];
        _captureParam.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    }
    return _captureParam;
    
}
@end
