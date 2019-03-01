//
//  Mine_AuthLogic.h
//  GKHelpOutApp
//
//  Created by 狂生烈徒 on 2019/2/28.
//  Copyright © 2019年 kky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Mine_AuthLogic : HpBaseLogic
@property (nonatomic , strong) NSString *gender;
@property (nonatomic , strong) NSString *name;
@property (nonatomic , assign) NSInteger workExperience;//工作经验
@property (nonatomic , strong) NSString *lawDescription;//律师简介
@property (nonatomic , strong) NSArray *categories;
@property (nonatomic , strong) NSMutableArray *LawyerCategories;
@property (nonatomic , strong) NSString*level;
@property (nonatomic , strong) NSString*lawOffice;
@property (nonatomic , strong) NSArray *certificatePictures;
@property (nonatomic , strong) NSArray *assessmentPictures;
@property (nonatomic , strong) NSArray *identificationPictures;
@property (nonatomic , strong) NSDictionary *lawOfficeAddress;
- (void)checkDataWithLawyerBasicCallback:(CheckDataCallback)callback;
- (void)getCertificationData:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;

@end
