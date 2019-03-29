//
//  AppDelegate.m
//  SealClass
//
//  Created by LiFei on 2019/2/25.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import <RongIMLib/RongIMLib.h>
#import "MessageHelper.h"
#import "IMService.h"
#import <Bugly/Bugly.h>
NSString *const APPKey = @"Your AppKey";
NSString *const BuglyKey = @"Your BuglyKey";

#define LOG_EXPIRE_TIME (-7 * 24 * 60 * 60)
@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - Life cycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configIM];
    
#ifndef DEBUG
    [self redirectNSlogToDocumentFolder];
    [Bugly startWithAppId:BuglyKey];
#endif
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    LoginViewController *vc = [[LoginViewController alloc] init];
    UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = naviVC;
    [self setNaviUI];
    return YES;
}

#pragma mark -
- (void)configIM {
    NSAssert(![APPKey isEqualToString:@"Your AppKey"], @"AppKey 不合法，请使用您自己的 AppKey, 注册地址：https://www.rongcloud.cn");
    [IMClient initWithAppKey:APPKey];
    [IMClient setReceiveMessageDelegate:[IMService sharedService] object:nil];
    IMClient.logLevel = RC_Log_Level_Info;
}

- (void)setNaviUI{
    //统一导航条样式
    UIFont *font = [UIFont systemFontOfSize:17.f];
    NSDictionary *textAttributes = @{NSFontAttributeName : font, NSForegroundColorAttributeName : HEXCOLOR(0x262626)};
    [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
    [[UINavigationBar appearance] setTintColor:HEXCOLOR(0x21c194)];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-1.5, 0)
                                                        forBarMetrics:UIBarMetricsDefault];
}

- (void)redirectNSlogToDocumentFolder {
    NSLog(@"Log重定向到本地，如果您需要控制台Log，注释掉重定向逻辑即可。");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    [self removeExpireLogFiles:documentDirectory];
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"MMddHHmmss"];
    NSString *formattedDate = [dateformatter stringFromDate:currentDate];
    
    NSString *fileName = [NSString stringWithFormat:@"rc%@.log", formattedDate];
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

- (void)removeExpireLogFiles:(NSString *)logPath {
    //删除超过时间的log文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileList = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:logPath error:nil]];
    NSDate *currentDate = [NSDate date];
    NSDate *expireDate = [NSDate dateWithTimeIntervalSinceNow:LOG_EXPIRE_TIME];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour |
    NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *fileComp = [calendar components:unitFlags fromDate:currentDate];
    for (NSString *fileName in fileList) {
        // rcMMddHHmmss.log length is 16
        if (fileName.length != 16) {
            continue;
        }
        if (![[fileName substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"rc"]) {
            continue;
        }
        int month = [[fileName substringWithRange:NSMakeRange(2, 2)] intValue];
        int date = [[fileName substringWithRange:NSMakeRange(4, 2)] intValue];
        if (month > 0) {
            [fileComp setMonth:month];
        } else {
            continue;
        }
        if (date > 0) {
            [fileComp setDay:date];
        } else {
            continue;
        }
        NSDate *fileDate = [calendar dateFromComponents:fileComp];
        
        if ([fileDate compare:currentDate] == NSOrderedDescending ||
            [fileDate compare:expireDate] == NSOrderedAscending) {
            [fileManager removeItemAtPath:[logPath stringByAppendingPathComponent:fileName] error:nil];
        }
    }
}

@end
