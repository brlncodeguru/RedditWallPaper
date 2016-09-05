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

@end
