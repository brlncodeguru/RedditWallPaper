//
//  RWCollectionViewCell.h
//  RedditWallPaper
//
//  Created by Lakshminarayana B R on 9/4/16.
//  Copyright © 2016 Lakshminarayana B R. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RWCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgThumbNail;
-(void)configureCell:(UIImage *)imageThumbNail;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorRW;

@end
