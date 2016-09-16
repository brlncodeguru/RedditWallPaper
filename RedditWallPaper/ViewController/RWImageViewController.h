//
//  RWImageViewController.h
//  RedditWallPaper
//
//  Created by Lakshminarayana B R on 9/4/16.
//  Copyright © 2016 Lakshminarayana B R. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RWImageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imgVwSource;
@property (weak, nonatomic) IBOutlet UILabel *lblError;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollVwImage;

@end
