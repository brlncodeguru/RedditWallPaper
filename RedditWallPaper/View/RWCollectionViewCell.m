//
//  RWCollectionViewCell.m
//  RedditWallPaper
//
//  Created by Lakshminarayana B R on 9/4/16.
//  Copyright © 2016 Lakshminarayana B R. All rights reserved.
//

#import "RWCollectionViewCell.h"

@implementation RWCollectionViewCell
@synthesize imgThumbNail,activityIndicatorRW;
- (void)awakeFromNib {
    [super awakeFromNib];

    // Initialization code
}

-(void)configureCell:(UIImage *)imageThumbNail
{
    
    imageThumbNail=[[UIImage alloc]init];
    imgThumbNail.image=imageThumbNail;
    imgThumbNail.layer.cornerRadius=8;
    imgThumbNail.clipsToBounds=YES;
    
    
}

@end
