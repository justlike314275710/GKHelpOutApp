//
//  authBaseTableViewCell.h
//  GKHelpOutApp
//
//  Created by 狂生烈徒 on 2019/2/27.
//  Copyright © 2019年 kky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface authBaseTableViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLbl;//标题
@property (nonatomic, strong) UITextField *detaileLbl;//内容
@property (nonatomic, strong) UIImageView *arrowIcon;//右箭头图标
@property (nonatomic , assign) BOOL isShow;
@end
