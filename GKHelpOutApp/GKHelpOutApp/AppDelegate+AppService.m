//
//  AppDelegate+AppService.m
//  MiAiApp
//
//  Created by 徐阳 on 2017/5/19.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "AppDelegate+AppService.h"
#import <UMSocialCore/UMSocialCore.h>
#import "LoginViewController.h"
#import "OpenUDID.h"
#import "IQKeyboardManager.h"
#import "WXApi.h"
#import "PSPayCenter.h"
#import "KGStatusBar.h"

@implementation AppDelegate (AppService)


#pragma mark ————— 初始化服务 —————
-(void)initService{
    //注册登录状态监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStateChange:)
                                                 name:KNotificationLoginStateChange
                                               object:nil];    
    
    //网络状态监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(netWorkStateChange:)
                                                 name:KNotificationNetWorkStateChange
                                               object:nil];
}

#pragma mark ————— 初始化window —————
-(void)initWindow{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = KWhiteColor;
    [self.window makeKeyAndVisible];
    [[UIButton appearance] setExclusiveTouch:YES];
//    [[UIButton appearance] setShowsTouchWhenHighlighted:YES];
    [UIActivityIndicatorView appearanceWhenContainedIn:[MBProgressHUD class], nil].color = KWhiteColor;
    if (@available(iOS 11.0, *)){
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
}


#pragma mark ————— 初始化用户系统 —————
-(void)initUserManager{
    DLog(@"设备IMEI ：%@",[OpenUDID value]);
    if([help_userManager loadUserInfo]){
        //加载用户token
        [help_userManager loadUserOuathInfo];
        //加载律师用户资料
        [help_userManager loadLawUserInfo];
        
        //如果有本地数据，先展示TabBar 随后异步自动登录
        self.mainTabBar = [MainTabBarController new];
        self.window.rootViewController = self.mainTabBar;
        
//        自动登录
        [help_userManager autoLoginToServer:^(BOOL success, NSString *des) {
            if (success) {
                DLog(@"自动登录成功");
                //                    [MBProgressHUD showSuccessMessage:@"自动登录成功"];
                KPostNotification(KNotificationAutoLoginSuccess, nil);
            }else{
//                [MBProgressHUD showErrorMessage:NSStringFormat(@"自动登录失败：%@",des)];
                [PSTipsView showTips:@"自动登录失败"];
            }
        }];

        
    }else{
        //没有登录过，展示登录页面
        KPostNotification(KNotificationLoginStateChange, @NO)
    }
}
#pragma mark ————— 注册第三方库 —————
- (void)registerThirdParty {
    //键盘
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    
    //微信
    [WXApi registerApp:kAppKey_Wechat];
    
    
}

#pragma mark ————— 登录状态处理 —————
- (void)loginStateChange:(NSNotification *)notification
{
    BOOL loginSuccess = [notification.object boolValue];

    if (loginSuccess) {//登陆成功加载主窗口控制器
        
        //为避免自动登录成功刷新tabbar
        if (!self.mainTabBar || ![self.window.rootViewController isKindOfClass:[MainTabBarController class]]) {
            self.mainTabBar = [MainTabBarController new];

            CATransition *anima = [CATransition animation];
            anima.type = @"cube";//设置动画的类型
            anima.subtype = kCATransitionFromRight; //设置动画的方向
            anima.duration = 0.3f;
            
            self.window.rootViewController = self.mainTabBar;
            
            [kAppWindow.layer addAnimation:anima forKey:@"revealAnimation"];
            
        }
        
    }else {//登陆失败加载登陆页面控制器
        
        self.mainTabBar = nil;
        RootNavigationController *loginNavi =[[RootNavigationController alloc] initWithRootViewController:[LoginViewController new]];
        
        CATransition *anima = [CATransition animation];
        anima.type = @"fade";//设置动画的类型
        anima.subtype = kCATransitionFromRight; //设置动画的方向
        anima.duration = 0.3f;
        
        self.window.rootViewController = loginNavi;
        
        [kAppWindow.layer addAnimation:anima forKey:@"revealAnimation"];
        
    }
    //展示FPS
//    [AppManager showFPS];
}


#pragma mark ————— 网络状态变化 —————
- (void)netWorkStateChange:(NSNotification *)notification
{
    /*
    BOOL isNetWork = [notification.object boolValue];
    /*
    if (isNetWork) {//有网络
        if ([help_userManager loadUserInfo] && !isLogin) {//有用户数据 并且 未登录成功 重新来一次自动登录
            [help_userManager autoLoginToServer:^(BOOL success, NSString *des) {
                if (success) {
                    DLog(@"网络改变后，自动登录成功");
//                    [MBProgressHUD showSuccessMessage:@"网络改变后，自动登录成功"];
                    KPostNotification(KNotificationAutoLoginSuccess, nil);
                }else{
                    [MBProgressHUD showErrorMessage:NSStringFormat(@"自动登录失败：%@",des)];
                }
            }];
        }
        
    }else {//登陆失败加载登陆页面控制器
        [MBProgressHUD showTopTipMessage:@"网络状态不佳" isWindow:YES];
    }
     */
}


#pragma mark ————— 友盟 初始化 —————
-(void)initUMeng{
    /* 打开调试日志 */
    [[UMSocialManager defaultManager] openLog:YES];
    
    /* 设置友盟appkey */
    [[UMSocialManager defaultManager] setUmSocialAppkey:UMengKey];
    
    [self configUSharePlatforms];
}
#pragma mark ————— 配置第三方 —————
-(void)configUSharePlatforms{
    /* 设置微信的appKey和appSecret */
    //[[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:kAppKey_Wechat appSecret:kSecret_Wechat redirectURL:nil];
    /*
     * 移除相应平台的分享，如微信收藏
     */
    //[[UMSocialManager defaultManager] removePlatformProviderWithPlatformTypes:@[@(UMSocialPlatformType_WechatFavorite)]];
    
    /* 设置分享到QQ互联的appID
     * U-Share SDK为了兼容大部分平台命名，统一用appKey和appSecret进行参数设置，而QQ平台仅需将appID作为U-Share的appKey参数传进即可。
     */
    //[[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:kAppKey_Tencent/*设置QQ平台的appID*/  appSecret:nil redirectURL:nil];
}

#pragma mark ————— OpenURL 回调 —————

- (BOOL)handleURL:(NSURL *)url {
    
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[PSPayCenter payCenter] handleAliURL:url];
    }else if ([url.scheme isEqualToString:kAppKey_Wechat] && [url.host isEqualToString:@"pay"]) {
        //微信支付
        [[PSPayCenter payCenter] handleWeChatURL:url];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self handleURL:url];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [self handleURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self handleURL:url];
}

#pragma mark ————— 网络状态监听 —————
- (void)monitorNetworkStatus
{
    // 网络状态改变一次, networkStatusWithBlock就会响应一次
    [PPNetworkHelper networkStatusWithBlock:^(PPNetworkStatusType networkStatus) {
        
        switch (networkStatus) {
                // 未知网络
            case PPNetworkStatusUnknown:
            {
                DLog(@"网络环境：未知网络");
                [KGStatusBar dismiss];
                self.IS_NetWork = YES;
                // 无网络
            }
            case PPNetworkStatusNotReachable:
            {
                DLog(@"网络环境：无网络");
                KPostNotification(KNotificationNetWorkStateChange, @NO);
                NSString *msg =  @"当前网络不可用,请检查你的网络设置";
                [KGStatusBar showWithStatus:msg];
                self.IS_NetWork = NO;
            }
                break;
                // 手机网络
            case PPNetworkStatusReachableViaWWAN:
            {
                DLog(@"网络环境：手机自带网络");
                [KGStatusBar dismiss];
                // 无线网络
                self.IS_NetWork = YES;
            }
            case PPNetworkStatusReachableViaWiFi:
                DLog(@"网络环境：WiFi");
                [KGStatusBar dismiss];
                KPostNotification(KNotificationNetWorkStateChange, @YES);
                self.IS_NetWork = YES;
                break;
        }
        
    }];
    
}

+ (AppDelegate *)shareAppDelegate{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


-(UIViewController *)getCurrentVC{
    
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

-(UIViewController *)getCurrentUIVC
{
    UIViewController  *superVC = [self getCurrentVC];
    
    if ([superVC isKindOfClass:[UITabBarController class]]) {
        
        UIViewController  *tabSelectVC = ((UITabBarController*)superVC).selectedViewController;
        
        if ([tabSelectVC isKindOfClass:[UINavigationController class]]) {
            
            return ((UINavigationController*)tabSelectVC).viewControllers.lastObject;
        }
        return tabSelectVC;
    }else
        if ([superVC isKindOfClass:[UINavigationController class]]) {
            
            return ((UINavigationController*)superVC).viewControllers.lastObject;
        }
    return superVC;
}


@end
