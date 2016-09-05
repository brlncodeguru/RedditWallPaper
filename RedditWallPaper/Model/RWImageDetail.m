//
//  RWImageDetail.m
//  RedditWallPaper
//
//  Created by Lakshminarayana B R on 9/3/16.
//  Copyright © 2016 Lakshminarayana B R. All rights reserved.
//

#import "RWImageDetail.h"


@implementation RWImageDetail
@synthesize imageURL,width,height;
-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:imageURL forKey:@"imageURL"];
    [encoder encodeObject:[NSNumber numberWithInteger:width] forKey:@"width"];
    [encoder encodeObject:[NSNumber numberWithInteger:height] forKey:@"height"];
    
    
    
    
}
-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if ( self != nil )
    {
        //decode the properties
        self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
        self.width = [[decoder decodeObjectForKey:@"variants"]integerValue];
        self.height=[[decoder decodeObjectForKey:@"variants"]integerValue];
        
    }
    return self;
}


@end
