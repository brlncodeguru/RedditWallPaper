//
//  RWImageSet.h
//  RedditWallPaper
//
//  Created by Lakshminarayana B R on 9/3/16.
//  Copyright © 2016 Lakshminarayana B R. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RWImageDetail.h"

@interface RWImageSet : NSObject
@property (nonatomic,strong)NSURL *thumbnailURL;
@property (nonatomic,strong) NSURL *imageSourceURL;

@property(nonatomic,strong)RWImageDetail *sourceImage;
@property(nonatomic,strong)NSMutableArray *marrResolutions;
@property(nonatomic,strong)NSMutableArray *marrVariants;
@property(nonatomic,strong)NSString *imageID;



@end
