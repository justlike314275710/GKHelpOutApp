//
//  LifeCircleViewController.h
//  GKHelpOutApp
//
//  Created by kky on 2019/4/15.
//  Copyright © 2019年 kky. All rights reserved.
//

#import "ZZFlexibleLayoutViewController.h"
#import "BaseRootViewController.h"
typedef NS_ENUM(NSInteger, TLMomentsVCSectionType) {
    TLMomentsVCSectionTypeHeader,
    TLMomentsVCSectionTypeItems,
};

typedef NS_ENUM(NSInteger, TLMomentsVCNewDataPosition) {
    TLMomentsVCNewDataPositionHead,
    TLMomentsVCNewDataPositionTail,
};

NS_ASSUME_NONNULL_BEGIN

@interface LifeCircleViewController : BaseRootViewController

@end

NS_ASSUME_NONNULL_END
