//
//  RWViewController.h
//  RedditWallPaper
//
//  Created by Lakshminarayana B R on 9/3/16.
//  Copyright © 2016 Lakshminarayana B R. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RWBusinessLayer.h"
#import "RWImageSet.h"
#import "RWImageDetail.h"
#import "RWImageViewController.h"
#import "Reachability.h"

@interface RWViewController : UIViewController<UITabBarDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *rwCollectionView;

@property(nonatomic,strong)NSCache *cacheData;
@property(nonatomic,strong)NSCache *imageCacheData;
@property(nonatomic,strong)NSArray *arrImageSet;
@property (nonatomic,strong)NSMutableDictionary *favouritesDict;
@property (nonatomic, strong) IBOutlet UICollectionViewFlowLayout *flowLayout;

@property (weak, nonatomic) IBOutlet UITabBar *tabBarSelection;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabBarItemLeft;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabBarItemRight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rwCollectionBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rwCollectionTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rwCollectionLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rwCollectionTopConstraint;
@property(strong,nonatomic)RWImageViewController *imgVC;
@property(strong,nonatomic)RWImageSet *selectedImageSet;

@property(strong,nonatomic)NSMutableArray *marrSavedPhotos;
@property(assign,nonatomic)Boolean isViewDidLoadCalled;

@property(strong,nonatomic)Reachability *hostReachable;
@property(strong,nonatomic)Reachability *internetReachable;

@property(assign,nonatomic)Boolean hostActive;
@property(assign,nonatomic)Boolean internetActive;

@property(assign,nonatomic)Boolean isImageViewScreen;

@property(strong,nonatomic)NSThread *currentThread;

@property (weak, nonatomic) IBOutlet UILabel *lblError;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mainActivityIndicator;


@end
