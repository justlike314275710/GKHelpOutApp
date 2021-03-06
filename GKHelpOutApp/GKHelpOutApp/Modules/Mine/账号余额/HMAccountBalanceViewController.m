//
//  HMAccountBalanceViewController.m
//  GKHelpOutApp
//
//  Created by kky on 2019/3/4.
//  Copyright © 2019年 kky. All rights reserved.
//

#import "HMAccountBalanceViewController.h"
#import "MineTableViewCell.h"
#import "HMActionSheetView.h"
#import "HMGetCashViewController.h"
#import "HMAccontBalaceLogic.h"
#import <AlipaySDK/AlipaySDK.h>
#import "LawUserInfo.h"
#import "PSAlertView.h"
#import "Mine_AuthLogic.h"
@interface HMAccountBalanceViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>{
    NSArray *_dataSource;
    BOOL _isBind;
}
@property(nonatomic, strong) UIView *headView;
@property(nonatomic, strong) UIImageView *HeadBgImg;
@property(nonatomic, strong) UILabel *balanceLab;
@property(nonatomic, strong) UILabel *k_balanceLab;
@property(nonatomic, strong) HMAccontBalaceLogic *Logic; //逻辑层
@property(nonatomic, strong) LawUserInfo *lawUserInfo;   //绑定的支付宝账户信息



@end

@implementation HMAccountBalanceViewController

#pragma mark -lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"账户余额";
     _Logic = [[HMAccontBalaceLogic alloc] init];
    //绑定支付宝结果回调
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gobingAlipy:)
                                                 name:KNotificationBingAliPay
                                               object:nil];
    //提现成功回调通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getCashSuccess)
                                                 name:KNotificationGetCashSuccess
                                               object:nil];
    
    
    [self setupUI];
    [self searchAlilpay];
}

#pragma mark -PravateMethods
-(void)setupData{
    NSString*alipayBind = help_userManager.lawUserInfo.alipayBind;
    NSString*aliPayAccount  =@"";
    if (!alipayBind||[alipayBind integerValue]==0) {
        aliPayAccount = @"未绑定";
        _isBind = NO;
    } else {
        aliPayAccount = self.lawUserInfo.nickName?self.lawUserInfo.nickName:@"";
        _isBind = YES;
    }
    NSDictionary *Modifydata = @{@"titleText":@"支付宝账户",@"title_icon":@"支付宝账号icon",@"clickSelector":@"",@"detailText":aliPayAccount,@"arrow_icon":@"myarrow_icon"};
    
    NSDictionary *myMission = @{@"titleText":@"申请提现",@"title_icon":@"申请提现icon",@"clickSelector":@"",@"arrow_icon":@"myarrow_icon"};
    
    _dataSource = @[Modifydata,myMission];
    [self.tableView reloadData];
}

-(void)setupUI{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, KScreenWidth, KScreenHeight - kTabBarHeight) style:UITableViewStyleGrouped];
    [self.tableView registerClass:[MineTableViewCell class] forCellReuseIdentifier:@"MineTableViewCell"];
    self.tableView.mj_header.hidden = YES;
    self.tableView.mj_footer.hidden = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

#pragma mark - TouchEvent

#pragma mark - Delegate&Datalist
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MineTableViewCell" forIndexPath:indexPath];
    cell.cellData = _dataSource[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    self.headView.frame = CGRectMake(0,0,KScreenWidth,200);
    self.HeadBgImg.frame = CGRectMake(24,30,KScreenWidth-48,154);
    self.k_balanceLab.frame = CGRectMake((self.HeadBgImg.width-200)/2,28,200, 20);
    self.balanceLab.frame = CGRectMake((self.HeadBgImg.width-200)/2,self.k_balanceLab.bottom+5,200,40);
    return self.headView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 200;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            if (_isBind) {
            HMActionSheetView *alert = [[HMActionSheetView alloc]initWithTitleArray:@[@"解绑"] andShowCancel:YES];
            alert.ClickIndex = ^(NSInteger index) {
                if (index == 1){
                    [self unbingAlipay];
                }
            };
            [alert show];
            } else {
                NSLog(@"绑定");
                [self bingAlipy];
            }
        }
            break;
        case 1:
        {
            [self getCash];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 提现
-(void)getCash{
    if ([help_userManager.lawUserInfo.alipayBind integerValue] !=1) {
        [PSTipsView showTips:@"需先绑定支付宝才能提现！"];
    } else {
        HMGetCashViewController *GetCashVC = [[HMGetCashViewController alloc] init];
        [self.navigationController pushViewController:GetCashVC animated:YES];
    }
}
#pragma mark - 提现成功回调
//获取余额
-(void)getCashSuccess{
    
    Mine_AuthLogic *authLogin = [Mine_AuthLogic new];
    [authLogin getLawyerProfilesData:^(id data) {
        if (ValidDict(data)) {
            NSString *userStaus = [data valueForKey:@"certificationStatus"];
            if ([userStaus isEqualToString:@"PENDING_CERTIFIED"]) {
                help_userManager.userStatus = PENDING_CERTIFIED;
            } else if ([userStaus isEqualToString:@"PENDING_APPROVAL"]){
                help_userManager.userStatus = PENDING_APPROVAL;
            } else if ([userStaus isEqualToString:@"APPROVAL_FAILURE"]){
                help_userManager.userStatus = APPROVAL_FAILURE;
            } else if ([userStaus isEqualToString:@"CERTIFIED"]){
                help_userManager.userStatus = CERTIFIED;
            }
            [help_userManager saveUserState];
            LawUserInfo *lawUserInfo = [LawUserInfo modelWithJSON:data];
            self.lawUserInfo = lawUserInfo;
            [help_userManager saveLawUserInfo];
            //刷新界面
            [self searchAlilpay];
            //刷新个人中心
            KPostNotification(KNotificationMineDataChange, nil);
        }
    } failed:^(NSError *error) {
        if (![help_userManager loadUserState]) {
            help_userManager.userStatus = PENDING_CERTIFIED;
        }
    }];
}

#pragma mark - 获取绑定人信息
-(void)searchAlilpay{
    [[PSLoadingView sharedInstance] show];
    [_Logic getBingLawyerAlipayInfo:^(id data) {
        [[PSLoadingView sharedInstance] dismiss];
        if (ValidDict(data)) {
            LawUserInfo *aliPayInfo = [LawUserInfo modelWithJSON:data];
            self.lawUserInfo = aliPayInfo;
            //修改绑定状态
            help_userManager.lawUserInfo.alipayBind = @"1";
            help_userManager.lawUserInfo.nickName = aliPayInfo.nickName;
            help_userManager.lawUserInfo.avatar = aliPayInfo.avatar;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setupData];
            });
        }
    } failed:^(NSError *error) {
        [[PSLoadingView sharedInstance] dismiss];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupData];
        });
    }];
}
#pragma mark - 解绑支付宝
-(void)unbingAlipay {
    [[PSLoadingView sharedInstance] show];
    [_Logic postUnBingLawyerAlipayData:^(id data) {
        [[PSLoadingView sharedInstance] dismiss];
        [PSTipsView showTips:@"支付宝解绑成功"];
        help_userManager.lawUserInfo.alipayBind = @"0";
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupData];
        });
    } failed:^(NSError *error) {
        [[PSLoadingView sharedInstance] dismiss];
        [PSTipsView showTips:@"支付宝解绑失败"];
    }];
}
#pragma mark - 绑定支付宝
-(void)gobingAlipy:(NSNotification *)notification{
    NSString *result = notification.object;
    if (ValidStr(result)) {
        if (result.length<=0)  return;
         [[PSLoadingView sharedInstance] show];
        [_Logic postBingLawyerAlipayData:result completed:^(id data) {
            [[PSLoadingView sharedInstance] dismiss];
            [PSTipsView showTips:@"支付宝绑定成功"];
            //查询绑定账户
            help_userManager.lawUserInfo.alipayBind = @"1";
            [self searchAlilpay];
        } failed:^(NSError *error) {
            [[PSLoadingView sharedInstance] dismiss];
            [PSTipsView showTips:@"支付宝绑定失败"];
            help_userManager.lawUserInfo.alipayBind = @"0";
            
        }];
    }
}
//认证授权
-(void)bingAlipy{
    [[PSLoadingView sharedInstance] show];
    [_Logic getBingLawyerAuthSignData:^(id data) {
        if (ValidDict(data)) {
            [[PSLoadingView sharedInstance] dismiss];
            NSString *sign = data[@"sign"];
            [[AlipaySDK defaultService] auth_V2WithInfo:sign fromScheme:AppScheme callback:^(NSDictionary *resultDic) {
                NSLog(@"result = %@",resultDic);
                // 解析 auth code
                NSString *result = resultDic[@"result"];
                NSString *authCode = nil;
                if (result.length>0) {
                    NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                    for (NSString *subResult in resultArr) {
                        if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                            authCode = [subResult substringFromIndex:10];
                            break;
                        }
                    }
                }
                NSLog(@"授权结果 authCode = %@", authCode?:@"");
            }];
        }
    } failed:^(NSError *error) {
        [[PSLoadingView sharedInstance] dismiss];
    }];
}

#pragma mark -Setting&Getting
-(UIView*)headView{
    if (!_headView) {
        _headView = [UIView new];
        _headView.backgroundColor = KWhiteColor;
       [ _headView addSubview:self.HeadBgImg];
    }
    return _headView;
}
-(UIImageView*)HeadBgImg{
    if (!_HeadBgImg) {
        _HeadBgImg = [UIImageView new];
        _HeadBgImg.image = IMAGE_NAMED(@"矩形45");
        [_HeadBgImg addSubview:self.k_balanceLab];
        [_HeadBgImg addSubview:self.balanceLab];
    }
    return _HeadBgImg;
}
-(UILabel*)balanceLab{
    if (!_balanceLab) {
        _balanceLab=[UILabel new];
        _balanceLab.text = @"666.00";
        NSString *accont = help_userManager.lawUserInfo.rewardAmount?help_userManager.lawUserInfo.rewardAmount:@"";
        if (accont.length>0) {
            accont = NSStringFormat(@"%@",accont);
        } else {
            accont = @"0.00";
        }
        _balanceLab.text = accont;
        _balanceLab.textAlignment = NSTextAlignmentCenter;
        _balanceLab.font = FontOfSize(38);
        _balanceLab.textColor=KWhiteColor;
    }
    return _balanceLab;
}
-(UILabel*)k_balanceLab{
    if (!_k_balanceLab) {
        _k_balanceLab=[UILabel new];
        _k_balanceLab.text = @"当前余额";
        _k_balanceLab.textAlignment = NSTextAlignmentCenter;
        _k_balanceLab.font = FFont1;
        _k_balanceLab.textColor=UIColorFromRGB(228,227,227);
    }
    return _k_balanceLab;
}





@end
