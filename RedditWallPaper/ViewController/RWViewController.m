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

@end

@implementation RWViewController
@synthesize cacheData,arrImageSet,imageCacheData,tabBarItemLeft,tabBarItemRight,tabBarSelection,favouritesDict,imgVC;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Data ");
//    tabBarSelection=[[UITabBar alloc]init];
    favouritesDict=[[NSMutableDictionary alloc]init];
    [[UITabBar appearance]setTintColor:[UIColor redColor]];
    
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
    [self parseJSON];
    self.rwCollectionView.backgroundColor = [UIColor whiteColor];
    [self.tabBarSelection setDelegate:(id)self];
    self.tabBarSelection.selectedItem=self.tabBarItemRight;
    [self.tabBarItemRight setImage:[UIImage imageNamed:@"square-rounded-512"]];
    [self.tabBarItemLeft setImage:[UIImage imageNamed:@"star-128"]];
    

    
}
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

}



-(void)parseJSON
{
//    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: (id)self delegateQueue: [NSOperationQueue mainQueue]];
//
    
    NSString *dataUrl = @"https://www.reddit.com/r/wallpapers/.json";
    NSURL *url = [NSURL URLWithString:dataUrl];
//    NSError *error;
//    NSString *json = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
//    
//    NSLog(@"\nJSON: %@ \n Error: %@", json, error);
////    NSData *data=[NSData dataWithContentsOfURL:url];
//    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"%@",jsonData);
//    NSMutableDictionary *mdict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
//    
//    NSLog(@"JSON: %@", mdict);
////    NSMutableDictionary *mdict=[NSMutableDictionary dictionaryWithContentsOfFile:json];
//    [cacheData setObject:mdict forKey:@"ImageData"];
//    
    

    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            
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
                                              
                                            
                                              
                                          }];
    
    
    [downloadTask resume];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  
    return arrImageSet.count; }

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"RWCell";
    RWCollectionViewCell *customRWCell= [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    RWImageSet *objImageSet=[[RWImageSet alloc]init];
    objImageSet=[arrImageSet objectAtIndex:indexPath.row];

//    [self.rwCollectionView registerClass:[RWCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    
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
    
    RWImageSet *imgSet=[[RWImageSet alloc]init];
    imgSet=[arrImageSet objectAtIndex:indexPath.row];
    _selectedImageSet=imgSet;
    [self.rwCollectionView removeConstraints:[NSArray arrayWithObjects:_rwCollectionTopConstraint,_rwCollectionBottomConstraint,_rwCollectionLeadingConstraint,_rwCollectionTrailingConstraint, nil]];
    [self.rwCollectionView removeFromSuperview];
    imgVC=[[RWImageViewController alloc]init];
    imgVC.view.tag=3;
    [imgVC.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:imgVC.view];
    NSLayoutConstraint *vcTopConstraint=[NSLayoutConstraint constraintWithItem:imgVC.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0f];
    NSLayoutConstraint *vcBottomConstraint=[NSLayoutConstraint constraintWithItem:imgVC.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-50.0f];
    NSLayoutConstraint *vcLeadingConstraint=[NSLayoutConstraint constraintWithItem:imgVC.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0f];
    NSLayoutConstraint *vcTrailingConstraint=[NSLayoutConstraint constraintWithItem:imgVC.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0f];

    
    
    [self.view addConstraints:[NSArray arrayWithObjects:vcTopConstraint,vcBottomConstraint,vcLeadingConstraint,vcTrailingConstraint, nil]];
    [self.tabBarItemLeft setImage:[UIImage imageNamed:@"dM1qs"]];
    [self.tabBarItemRight setImage:[UIImage imageNamed:@"star-128"]];
    [self.tabBarSelection setSelectedItem:nil];
    for(NSString *str in favouritesDict.allKeys)
    {
        if([str isEqualToString:_selectedImageSet.imageID])
        {
            if([tabBarItemRight.image isEqual:[UIImage imageNamed:@"star-128"]])
            {
                NSLog(@" ****#####star image");
            }
            else
            {
                NSLog(@" ****#####not star image");
                
            }
            [self.tabBarSelection setSelectedItem:tabBarItemRight];
            if([tabBarItemRight.image isEqual:[UIImage imageNamed:@"star-128"]])
            {
                NSLog(@" ****#####star image");
            }
            else
            {
                NSLog(@" ****#####not star image");
                
            }
        }
    }
    

    [self.tabBarItemLeft setTitle:@"Back"];
    [self.tabBarItemRight setTitle:@"Set Favorite"];
    
    [self getImagefromURLinImageSet:imgSet];

    
}
-(void)getImagefromURLinImageSet:(RWImageSet *)imgSet
{
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:imgSet.imageSourceURL  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              
                                              //                                              NSError *error1;
                                              //                                              NSLog(@"Data =%@",data);
                                              if(data!=nil)
                                              {
                                                  
                                                  
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      
                                                      if(data!=nil)
                                                      {
                                                          imgVC.imgVwSource.image=[UIImage imageWithData:data];
                                                          if([tabBarItemRight.image isEqual:[UIImage imageNamed:@"star-128"]])
                                                          {
                                                              NSLog(@" ****#####star image");
                                                          }
                                                          else
                                                          {
                                                              NSLog(@" ****#####not star image");
                                                              
                                                          }

                                                      }
                                                      
                                                  });
                                                  
                                                  
                                              }
                                              
                                              
                                              
                                          }];
    
    [downloadTask resume];
    
    

}

-(void)getImageFromURL:(NSURL *)url forCell:(RWCollectionViewCell *)customRWCell forImageSet:(RWImageSet *)objImageSet {
    __block NSData *imageData;
    
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              
//                                              NSError *error1;
//                                              NSLog(@"Data =%@",data);
                                              if(data!=nil)
                                              {
                                                  [imageCacheData setObject:data forKey:objImageSet.imageID];
                                                  imageData=data;
                                                  NSLog(@"imageData##### =%@",imageData);
                                                  
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
            for(UIView *subView in self.view.subviews)
            {
                if(subView.tag==3)
                {
                    UIView *vwImgVC=(UILabel *)subView;
                    [vwImgVC removeConstraints:vwImgVC.constraints];
                    [vwImgVC removeFromSuperview];
                    [self.rwCollectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self.view addSubview:self.rwCollectionView];
                    
                    
                    [self.view addConstraints:[NSArray arrayWithObjects:_rwCollectionTopConstraint,_rwCollectionBottomConstraint,_rwCollectionLeadingConstraint,_rwCollectionTrailingConstraint, nil]];
                    
                    
                }
            }
            [self.rwCollectionView reloadData];

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
                if([item.image isEqual:[UIImage imageNamed:@"star-128"]])
                {
                    NSLog(@" ****#####star image");
                }
                else
                {
                    NSLog(@" ****#####not star image");

                }
                [tabBar setSelectedItem:nil];
                if([item.image isEqual:[UIImage imageNamed:@"star-128"]])
                {
                    NSLog(@" ****#####star image");
                }
                else
                {
                    NSLog(@" ****#####not star image");
                    
                }
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
   
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
