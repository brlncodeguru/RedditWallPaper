//
//  RWImageSet.m
//  RedditWallPaper
//
//  Created by Lakshminarayana B R on 9/3/16.
//  Copyright © 2016 Lakshminarayana B R. All rights reserved.
//

#import "RWImageSet.h"

@implementation RWImageSet
@synthesize sourceImage,marrVariants,marrResolutions,imageID,imageSourceURL,thumbnailURL;
-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:sourceImage forKey:@"sourceImage"];
    [encoder encodeObject:marrVariants forKey:@"variants"];
    [encoder encodeObject:marrResolutions forKey:@"resolutions"];
    [encoder encodeObject:imageID forKey:@"imageID"];
    [encoder encodeObject:imageSourceURL forKey:@"imageSourceURL"];
    [encoder encodeObject:thumbnailURL forKey:@"thumbnailURL"];





}
-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if ( self != nil )
    {
        //decode the properties
        self.sourceImage = [decoder decodeObjectForKey:@"sourceImage"];
        self.marrVariants = [decoder decodeObjectForKey:@"variants"];
        self.marrResolutions=[decoder decodeObjectForKey:@"resolutions"];
        self.imageID=[decoder decodeObjectForKey:@"imageID"];
        self.imageSourceURL=[decoder decodeObjectForKey:@"imageSourceURL"];
        self.thumbnailURL=[decoder decodeObjectForKey:@"thumbnailURL"];
    }
    return self;
}


@end
