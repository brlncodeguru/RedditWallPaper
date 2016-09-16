//
//  RWViewController.m
//  RedditWallPaper
//
//  Created by Lakshminarayana B R on 9/3/16.
//  Copyright © 2016 Lakshminarayana B R. All rights reserved.
//

#import "RWViewController.h"
#import "RWBusinessLayer.h"
#import "RWCollectionViewCell.h"
#import "RWImageSet.h"
#import "RWImageDetail.h"
@interface RWViewController ()
{
    UISwipeGestureRecognizer *swipeLeft;
    UISwipeGestureRecognizer *swipeRight;
    
    
}

@end

@implementation RWViewController
@synthesize cacheData,arrImageSet,imageCacheData,tabBarItemLeft,tabBarItemRight,tabBarSelection,favouritesDict,imgVC,mainActivityIndicator;

#pragma-mark View Methods
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    _internetReachable = [Reachability reachabilityForInternetConnection];
    [_internetReachable startNotifier];
    
    
    _hostReachable = [Reachability reachabilityWithHostName:@"https://www.reddit.com/r/wallpapers/.json"];
    [_hostReachable startNotifier];
    
    
    if(!_isViewDidLoadCalled)
    {
        if(self.internetActive && self.hostActive)
            [self parseJSON];
    }
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    _isViewDidLoadCalled=NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:kReachabilityChangedNotification];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Data ");
    _isViewDidLoadCalled=YES;
    //    tabBarSelection=[[UITabBar alloc]init];
    favouritesDict=[[NSMutableDictionary alloc]init];
    [[UITabBar appearance]setTintColor:[UIColor redColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appplicationEnteredBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    _marrSavedPhotos=[[NSMutableArray alloc]init];
    if([[NSUserDefaults standardUserDefaults]valueForKey:@"Saved Photos"])
        _marrSavedPhotos=[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]valueForKey:@"Saved Photos"]];
    
    
    if([[NSUserDefaults standardUserDefaults]valueForKey:@"Favorites"])
        
    {
        NSMutableDictionary *mdict=[[NSUserDefaults standardUserDefaults]valueForKey:@"Favorites"];
        for(NSString *str in mdict.allKeys)
        {
            RWImageSet *imgSet=[NSKeyedUnarchiver unarchiveObjectWithData:[mdict valueForKey:str]];
            [favouritesDict setObject:imgSet forKey:str];
            
        }
    }
    
    
    cacheData=[[NSCache alloc]init];
    imageCacheData=[[NSCache alloc]init];
    if(self.internetActive && self.hostActive)
        [self parseJSON];
    else
    {
        if (arrImageSet.count==0) {
            _lblError.hidden=NO;
            [self.mainActivityIndicator stopAnimating];
            
            self.mainActivityIndicator.hidden=YES;
            
        }
    }
        
    self.rwCollectionView.backgroundColor = [UIColor whiteColor];
    [self.tabBarSelection setDelegate:(id)self];
    self.tabBarSelection.selectedItem=self.tabBarItemRight;
    [self.tabBarItemRight setImage:[UIImage imageNamed:@"square-rounded-512"]];
    [self.tabBarItemLeft setImage:[UIImage imageNamed:@"star-128"]];
    
    
    
}

#pragma-mark Network Reachablity

-(void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [_internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            self.internetActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            self.internetActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            self.internetActive = YES;
            
            break;
        }
    }
    
    NetworkStatus hostStatus = [_hostReachable currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {
            NSLog(@"A gateway to the host server is down.");
            self.hostActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"A gateway to the host server is working via WIFI.");
            self.hostActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"A gateway to the host server is working via WWAN.");
            self.hostActive = YES;
            
            break;
        }
    }
    if(self.internetActive && self.hostActive)
    {
        if(self.tabBarSelection.items.count==2 )
            [self parseJSON];
        else{
            _currentThread = [[NSThread   alloc]initWithTarget:self selector:@selector(getImagefromURLinImageSet:) object:_selectedImageSet];
            
            [_currentThread start];
            
        }
        
    }
    
    else{
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Reddit"
                                     message:@"Check your network connection"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:@"Ok"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                   }];
        
        
        [alert addAction:okButton];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        
    }
    
}

#pragma-mark Process Json and Set Models
-(void)setModel
{
    arrImageSet=[RWBusinessLayer setModelObjects:cacheData];
    
    self.rwCollectionView.dataSource=(id)self;
    self.rwCollectionView.delegate=(id)self;
    self.rwCollectionView.tag=1;
    
    [self.rwCollectionView registerNib:[UINib nibWithNibName:@"RWCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"RWCell"];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.minimumInteritemSpacing = 0.5f;
    
    [self.flowLayout setItemSize:CGSizeMake((screenWidth-2)/4, (screenHeight-2)/4)];
    [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.rwCollectionView setCollectionViewLayout:self.flowLayout];
    self.rwCollectionView.bounces = YES;
    [self.rwCollectionView setShowsHorizontalScrollIndicator:NO];
    [self.rwCollectionView setShowsVerticalScrollIndicator:NO];
    self.rwCollectionView.scrollEnabled= YES;
    
    if (arrImageSet.count==0) {
        _lblError.hidden=NO;
        [self.mainActivityIndicator stopAnimating];
        
        self.mainActivityIndicator.hidden=YES;
        
    }
    else
    {
        _lblError.hidden=YES;
        [self.mainActivityIndicator stopAnimating];
        
        self.mainActivityIndicator.hidden=YES;
    }
    
}



-(void)parseJSON
{
    [self.mainActivityIndicator startAnimating];
    
    self.mainActivityIndicator.hidden=NO;
    
    NSString *dataUrl = @"https://www.reddit.com/r/wallpapers/.json";
    NSURL *url = [NSURL URLWithString:dataUrl];
    
    
    
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              if(data!=nil)
                                              {
                                                  NSError *error1;
                                                  NSMutableDictionary * imageJson = [NSJSONSerialization
                                                                                     JSONObjectWithData:data
                                                                                     options:kNilOptions
                                                                                     error:&error1];
                                                  NSLog(@"Json$$$$$$$$$$ %@",imageJson);
                                                  
                                                  [cacheData setObject:imageJson forKey:@"ImageData"];
                                                  dispatch_async(dispatch_get_main_queue(),^ {
                                                      [self setModel];
                                                  });
                                                  
                                                  
                                                  
                                                  
                                              }
                                              else
                                              {
                                                  
                                              }
                                              
                                          }];
    
    
    [downloadTask resume];
}

#pragma-mark Collection View

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return arrImageSet.count; }

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"RWCell";
    RWCollectionViewCell *customRWCell= [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    RWImageSet *objImageSet;
    objImageSet=[arrImageSet objectAtIndex:indexPath.row];
    
    //    [self.rwCollectionView registerClass:[RWCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    customRWCell.imgThumbNail.layer.cornerRadius=8;
    customRWCell.imgThumbNail.clipsToBounds=YES;
    
    [customRWCell.activityIndicatorRW startAnimating];
    if([imageCacheData objectForKey:objImageSet.imageID])
    {
        [customRWCell.activityIndicatorRW stopAnimating];
        [customRWCell.activityIndicatorRW setHidden:YES];
        customRWCell.imgThumbNail.image = [UIImage imageWithData:[imageCacheData objectForKey:objImageSet.imageID]];
    }
    else
    {
        [self getImageFromURL:objImageSet.thumbnailURL forCell:customRWCell forImageSet:objImageSet];
        
    }
    
    
    
    return customRWCell;
    
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    RWImageSet *imgSet;
    imgSet=[arrImageSet objectAtIndex:indexPath.row];
    _selectedImageSet=imgSet;
    [self.rwCollectionView removeConstraints:[NSArray arrayWithObjects:_rwCollectionTopConstraint,_rwCollectionBottomConstraint,_rwCollectionLeadingConstraint,_rwCollectionTrailingConstraint, nil]];
    [self.rwCollectionView removeFromSuperview];
    imgVC=[[RWImageViewController alloc]init];
    imgVC.view.tag=3;
    imgVC.imgVwSource.userInteractionEnabled=YES;
    [imgVC.activityIndicatorImageView setHidden:NO];
    [imgVC.activityIndicatorImageView startAnimating];
    
    self.imgVC.scrollVwImage.contentSize = self.imgVC.imgVwSource.bounds.size;
    self.imgVC.scrollVwImage.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.imgVC.scrollVwImage.minimumZoomScale = 1.0f;
    self.imgVC.scrollVwImage.maximumZoomScale = 3.0f;
    self.imgVC.scrollVwImage.delegate = (id)imgVC;
    
    [imgVC.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:imgVC.view];
    NSLayoutConstraint *vcTopConstraint=[NSLayoutConstraint constraintWithItem:imgVC.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0f];
    NSLayoutConstraint *vcBottomConstraint=[NSLayoutConstraint constraintWithItem:imgVC.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-50.0f];
    NSLayoutConstraint *vcLeadingConstraint=[NSLayoutConstraint constraintWithItem:imgVC.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0f];
    NSLayoutConstraint *vcTrailingConstraint=[NSLayoutConstraint constraintWithItem:imgVC.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0f];
    //    NSLayoutConstraint *vcWidthConstraint=[NSLayoutConstraint constraintWithItem:imgVC.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.0f];
    
    
    
    [self.view addConstraints:[NSArray arrayWithObjects:vcTopConstraint,vcBottomConstraint,vcLeadingConstraint,vcTrailingConstraint, nil]];
    
    swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandle:)];
    
    swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandle:)];
    
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeRight];
    
    
    
    UITabBarItem *tabBarSave=[[UITabBarItem alloc]init];
    [tabBarSave setImage:[UIImage imageNamed:@"heart"]];
    [tabBarSave setTitle:@"Save and Share"];
    tabBarSave.tag=3;
    [self.tabBarItemLeft setImage:[UIImage imageNamed:@"dM1qs"]];
    [self.tabBarItemRight setImage:[UIImage imageNamed:@"star-128"]];
    [self.tabBarSelection setItems:[NSArray arrayWithObjects:self.tabBarItemLeft,self.tabBarItemRight,tabBarSave, nil]];
    [self.tabBarSelection setSelectedItem:nil];
    for(NSString *str in favouritesDict.allKeys)
    {
        if([str isEqualToString:_selectedImageSet.imageID])
        {
            [self.tabBarSelection setSelectedItem:tabBarItemRight];
        }
    }
    
    
    [self.tabBarItemLeft setTitle:@"Back"];
    [self.tabBarItemRight setTitle:@"Set Favorite"];
    NSArray *imageExtensions = @[@"png", @"jpg", @"gif"];
    
    
    //...
    
    
    NSString *extension = [imgSet.sourceImage.imageURL pathExtension];
    if ([imageExtensions containsObject:extension]) {
        NSLog(@"Image URL: %@", imgSet.imageSourceURL);
        if(self.internetActive&&self.hostActive)
        {
            _currentThread = [[NSThread   alloc]initWithTarget:self selector:@selector(getImagefromURLinImageSet:) object:imgSet];
            
            [_currentThread start];
            
        }
        else{
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Reddit"
                                         message:@"Check your network connection"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okButton = [UIAlertAction
                                       actionWithTitle:@"Ok"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           [self dismissViewControllerAnimated:YES completion:nil];
                                       }];
            
            
            [alert addAction:okButton];
            
            [self presentViewController:alert animated:YES completion:nil];
            
        }
        
        //            [self getImagefromURLinImageSet:imgSet];
    }
    else{
        [imgVC.activityIndicatorImageView stopAnimating];
        imgVC.activityIndicatorImageView.hidden=YES;
        imgVC.lblError.hidden=NO;
        
        
    }
    
    
}
#pragma-mark Download Image from URL
-(void)getImagefromURLinImageSet:(RWImageSet *)imgSet
{
    
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:imgSet.sourceImage.imageURL  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              
                                              if([_currentThread isCancelled])
                                                  return;
                                              
                                              
                                              if(data!=nil)
                                              {
                                                  
                                                  
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      
                                                      if(data!=nil)
                                                      {
                                                          
                                                          imgVC.imgVwSource.image=[UIImage imageWithData:data];
                                                          imgVC.imgVwSource.contentMode=UIViewContentModeScaleAspectFit;
                                                          [imgVC.activityIndicatorImageView stopAnimating];
                                                          imgVC.activityIndicatorImageView.hidden=YES;
                                                                                                                }
                                                      
                                                  });
                                                  
                                                  
                                              }
                                              else
                                              {
                                                  [imgVC.activityIndicatorImageView stopAnimating];
                                                  imgVC.activityIndicatorImageView.hidden=YES;
                                                  imgVC.lblError.hidden=NO;
                                              }
                                              
                                              
                                              
                                          }];
    
    [downloadTask resume];
    
    
    
}

-(void)getImageFromURL:(NSURL *)url forCell:(RWCollectionViewCell *)customRWCell forImageSet:(RWImageSet *)objImageSet {
    NSLog(@" #### imgSource URL  :%@",objImageSet.sourceImage.imageURL);
    __block NSData *imageData;
    
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              
                                              if(data!=nil)
                                              {
                                                  [imageCacheData setObject:data forKey:objImageSet.imageID];
                                                  imageData=data;
                                                  
                                                  
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      
                                                      if(imageData!=nil)
                                                      {
                                                          [customRWCell.activityIndicatorRW stopAnimating];
                                                          [customRWCell.activityIndicatorRW setHidden:YES];
                                                          customRWCell.imgThumbNail.image = [UIImage imageWithData:imageData];
                                                      }
                                                      
                                                  });
                                                  
                                                  
                                              }
                                              
                                              
                                              
                                          }];
    
    [downloadTask resume];
    
    
    
}
#pragma-mark TabBar
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if(item.tag==1)
    {
        if([item.title isEqualToString:@"Favorites"])
        {
            NSLog(@"Favourites selected");
            
            
            if(favouritesDict.allValues.count!=0)
            {
                arrImageSet=favouritesDict.allValues;
                
                [self.rwCollectionView reloadData];
                
            }
            else
            {
                [self.rwCollectionView removeConstraints:[NSArray arrayWithObjects:_rwCollectionTopConstraint,_rwCollectionBottomConstraint,_rwCollectionLeadingConstraint,_rwCollectionTrailingConstraint, nil]];
                [self.rwCollectionView removeFromSuperview];
                
                UILabel *lbl=[[UILabel alloc]init];
                [lbl setTranslatesAutoresizingMaskIntoConstraints:NO];
                
                lbl.tag=2;
                lbl.text=@"No Favourites";
                [self.view addSubview:lbl];
                
                NSLayoutConstraint *xCenterConstraint = [NSLayoutConstraint constraintWithItem:lbl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
                [self.view addConstraint:xCenterConstraint];
                
                NSLayoutConstraint *yCenterConstraint = [NSLayoutConstraint constraintWithItem:lbl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
                [self.view addConstraint:yCenterConstraint];
            }
            
            
        }
        else if ([item.title isEqualToString:@"Back"])
        {
            [_currentThread cancel];
            imgVC=nil;
            
            
            [self.view removeGestureRecognizer:swipeRight];
            [self.view removeGestureRecognizer:swipeLeft];
            
            
            
            for(UIView *subView in self.view.subviews)
            {
                if(subView.tag==3)
                {
                    UIView *vwImgVC=(UILabel *)subView;
                    [vwImgVC removeConstraints:vwImgVC.constraints];
                    [vwImgVC removeFromSuperview];
                    imgVC=nil;
                    [self.rwCollectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self.view addSubview:self.rwCollectionView];
                    
                    
                    [self.view addConstraints:[NSArray arrayWithObjects:_rwCollectionTopConstraint,_rwCollectionBottomConstraint,_rwCollectionLeadingConstraint,_rwCollectionTrailingConstraint, nil]];
                    
                    
                }
            }
            [self.rwCollectionView reloadData];
            [self.tabBarSelection setItems:[NSArray arrayWithObjects:self.tabBarItemLeft,self.tabBarItemRight, nil]];
            [self.tabBarItemRight setImage:[UIImage imageNamed:@"square-rounded-512"]];
            [self.tabBarItemLeft setImage:[UIImage imageNamed:@"star-128"]];
            
            
            [self.tabBarItemLeft setTitle:@"Favorites"];
            [self.tabBarItemRight setTitle:@"Collections"];
            [self tabBar:self.tabBarSelection didSelectItem:tabBarItemRight];
            [self.tabBarSelection setSelectedItem:tabBarItemRight];
            
            
        }
        
    }
    else if (item.tag==2)
    {
        if([item.title isEqualToString:@"Collections"])
        {
            for(UIView *subView in self.view.subviews)
            {
                if(subView.tag==2)
                {
                    UILabel *lbl=(UILabel *)subView;
                    [lbl removeConstraints:lbl.constraints];
                    [lbl removeFromSuperview];
                    [self.rwCollectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self.view addSubview:self.rwCollectionView];
                    
                    
                    [self.view addConstraints:[NSArray arrayWithObjects:_rwCollectionTopConstraint,_rwCollectionBottomConstraint,_rwCollectionLeadingConstraint,_rwCollectionTrailingConstraint, nil]];
                    
                    
                }
            }
            NSLog(@"Collections selected");
            arrImageSet=[RWBusinessLayer setModelObjects:cacheData];
            [self.rwCollectionView reloadData];
            
            
            
            
        }
        else if([item.title isEqualToString:@"Set Favorite"])
        {
            if([favouritesDict.allKeys containsObject:_selectedImageSet.imageID])
            {
                [tabBar setSelectedItem:nil];
                [favouritesDict removeObjectForKey:_selectedImageSet.imageID];
                
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"Reddit"
                                             message:@"Image Removed from Favorites"
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* okButton = [UIAlertAction
                                           actionWithTitle:@"Ok"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               [self dismissViewControllerAnimated:YES completion:nil];
                                           }];
                
                
                [alert addAction:okButton];
                
                [self presentViewController:alert animated:YES completion:nil];
                
            }
            else
            {
                
                
                [favouritesDict setObject:_selectedImageSet forKey:_selectedImageSet.imageID];
                NSMutableDictionary *mdict=[[NSMutableDictionary alloc]init];
                for(NSString *strkey in favouritesDict.allKeys)
                {
                    NSData *dataFav=[NSKeyedArchiver archivedDataWithRootObject:[favouritesDict valueForKey:strkey ]];
                    [mdict setObject:dataFav forKey:strkey];
                    
                }
                
                [[NSUserDefaults standardUserDefaults]setObject:mdict forKey:@"Favorites"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"Reddit"
                                             message:@"Added to Favorites"
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* okButton = [UIAlertAction
                                           actionWithTitle:@"Ok"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               [self dismissViewControllerAnimated:YES completion:nil];
                                           }];
                
                
                [alert addAction:okButton];
                
                [self presentViewController:alert animated:YES completion:nil];
                
            }
        }
    }
    else
    {
        UIImage *img=[UIImage imageWithData:[NSData dataWithContentsOfURL:_selectedImageSet.sourceImage.imageURL]];

        UIAlertController *alerController=[UIAlertController alertControllerWithTitle:@"Reddit" message:@"Select an Option" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction* saveButton = [UIAlertAction
                                   actionWithTitle:@"Save"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [_marrSavedPhotos addObject:_selectedImageSet.imageID];
                                       [[NSUserDefaults standardUserDefaults]setObject:_marrSavedPhotos forKey:@"Saved Photos"];
                                       
                                       UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
//                                       UIAlertController * alert = [UIAlertController
//                                                                    alertControllerWithTitle:@"Reddit"
//                                                                    message:@"Image saved"
//                                                                    preferredStyle:UIAlertControllerStyleAlert];
//                                       
//                                       UIAlertAction* okButton = [UIAlertAction
//                                                                  actionWithTitle:@"Ok"
//                                                                  style:UIAlertActionStyleDefault
//                                                                  handler:^(UIAlertAction * action) {
//                                                                      [self dismissViewControllerAnimated:YES completion:nil];
//                                                                  }];
//                                       
//                                       
//                                       [alert addAction:okButton];
//                                       
//                                       [self presentViewController:alert animated:YES completion:nil];
//
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                       
                                   }];
        
        UIAlertAction* shareButton = [UIAlertAction
                                       actionWithTitle:@"Share"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {

                                           
                                           NSString *textToShare=@"Cool Wallpapers for Your Use :-)";
                                           
                                           NSArray *objectsToShare = @[textToShare, img];
                                           
                                           UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
                                           
                                           NSArray *excludeActivities = @[UIActivityTypeSaveToCameraRoll,
                                                                          UIActivityTypeAddToReadingList];
                                           
                                           activityVC.excludedActivityTypes = excludeActivities;
                                           
                                           [self presentViewController:activityVC animated:YES completion:nil];

                                           
                                       }];

        
        UIAlertAction* cancelButton = [UIAlertAction
                                     actionWithTitle:@"Cancel"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                                                                  [self dismissViewControllerAnimated:YES completion:nil];
                                         
                                     }];
        
        
        
        
        
        
        [alerController addAction:saveButton];
        [alerController addAction:shareButton];

        [alerController addAction:cancelButton];
        
        [self presentViewController:alerController animated:YES completion:nil];
        
        

        
        
        
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma-mark Application

- (void)appplicationEnteredBackground:(NSNotification *)notification {
    NSLog(@"Application Did Become Active");
    _isViewDidLoadCalled=NO;
    
}

- (void)applicationEnteredForeground:(NSNotification *)notification {
    NSLog(@"Application Entered Foreground");
    if(!_isViewDidLoadCalled)
    {
        
        if(self.internetActive && self.hostActive)
            [self parseJSON];
        
    }
}
#pragma-mark Swipe Gesture Handler
- (void)swipeHandle:(UISwipeGestureRecognizer *)swipe {
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        
        NSLog(@"Left Swipe");
        NSArray *imageExtensions = @[@"png", @"jpg", @"gif"];
        
        
        //...
        if([arrImageSet indexOfObject:_selectedImageSet]+1>0 && [arrImageSet indexOfObject:_selectedImageSet]+1<[arrImageSet count])
        {
            RWImageSet *imgSet=[arrImageSet objectAtIndex:[arrImageSet indexOfObject:_selectedImageSet]+1];
            _selectedImageSet=imgSet;
            
            if(imgSet!=nil)
            {
                NSString *extension = [imgSet.sourceImage.imageURL pathExtension];
                if ([imageExtensions containsObject:extension]) {
                    NSLog(@"Image URL: %@", imgSet.imageSourceURL);
                    if(self.internetActive&&self.hostActive)
                    {
                        _currentThread = [[NSThread   alloc]initWithTarget:self selector:@selector(getImagefromURLinImageSet:) object:imgSet];
                        
                        [_currentThread start];
                        
                    }
                    else{
                        UIAlertController * alert = [UIAlertController
                                                     alertControllerWithTitle:@"Reddit"
                                                     message:@"Check your network connection"
                                                     preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* okButton = [UIAlertAction
                                                   actionWithTitle:@"Ok"
                                                   style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self dismissViewControllerAnimated:YES completion:nil];
                                                   }];
                        
                        
                        [alert addAction:okButton];
                        
                        [self presentViewController:alert animated:YES completion:nil];
                        
                    }
                    
                    //            [self getImagefromURLinImageSet:imgSet];
                }
                else{
                    [imgVC.activityIndicatorImageView stopAnimating];
                    imgVC.activityIndicatorImageView.hidden=YES;
                    imgVC.lblError.hidden=NO;
                    
                    
                }
                
            }
            
        }
        
        
        
        
        
        
        
    }
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        
        NSLog(@"Right Swipe");
        NSArray *imageExtensions = @[@"png", @"jpg", @"gif"];
        
        
        //...
        if([arrImageSet indexOfObject:_selectedImageSet]>0 && [arrImageSet indexOfObject:_selectedImageSet]-1<[arrImageSet count])
        {
            RWImageSet *imgSet=[arrImageSet objectAtIndex:[arrImageSet indexOfObject:_selectedImageSet]-1];
            _selectedImageSet=imgSet;
            if(imgSet!=nil)
            {
                NSString *extension = [imgSet.sourceImage.imageURL pathExtension];
                if ([imageExtensions containsObject:extension]) {
                    NSLog(@"Image URL: %@", imgSet.imageSourceURL);
                    if(self.internetActive&&self.hostActive)
                    {
                        _currentThread = [[NSThread   alloc]initWithTarget:self selector:@selector(getImagefromURLinImageSet:) object:imgSet];
                        
                        [_currentThread start];
                        
                    }
                    else{
                        UIAlertController * alert = [UIAlertController
                                                     alertControllerWithTitle:@"Reddit"
                                                     message:@"Check your network connection"
                                                     preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* okButton = [UIAlertAction
                                                   actionWithTitle:@"Ok"
                                                   style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self dismissViewControllerAnimated:YES completion:nil];
                                                   }];
                        
                        
                        [alert addAction:okButton];
                        
                        [self presentViewController:alert animated:YES completion:nil];
                        
                    }
                    
                    //            [self getImagefromURLinImageSet:imgSet];
                }
                else{
                    [imgVC.activityIndicatorImageView stopAnimating];
                    imgVC.activityIndicatorImageView.hidden=YES;
                    imgVC.lblError.hidden=NO;
                    
                    
                }
                
            }
            
            
        }
        
        
        
        
    }
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
