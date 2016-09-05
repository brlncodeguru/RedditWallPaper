//
//  RWBusinessLayer.m
//  RedditWallPaper
//
//  Created by Lakshminarayana B R on 9/3/16.
//  Copyright © 2016 Lakshminarayana B R. All rights reserved.
//

#import "RWBusinessLayer.h"
#import "RWImageSet.h"
#import "RWImageDetail.h"


@implementation RWBusinessLayer

+(NSArray*)setModelObjects:(NSCache *)jsonCache
{
    NSArray *arrImageSet;
    NSMutableArray *marrImageSet=[[NSMutableArray alloc]init];
    
    NSDictionary *dictCache=[[NSDictionary alloc]init];
    dictCache=[jsonCache objectForKey:@"ImageData"];

    
    for(NSString *key in dictCache.allKeys)
    {
        if([key isEqualToString:@"data"])
        {
            NSDictionary *dictData=[[NSDictionary alloc]init];
            dictData=[dictCache valueForKey:key];
            for(NSString *dataKey in dictData.allKeys)
            {
                if([dataKey isEqualToString:@"children"])
                {
                    NSArray *arrChildren=[NSArray arrayWithArray:[dictData valueForKey:dataKey]];
                    
                    for(NSDictionary *childDict in arrChildren)
                    {
                        RWImageSet *objImgSet=[[RWImageSet alloc]init];
                        for(NSString *childDictKey in childDict)
                        {
                            if([childDictKey isEqualToString:@"data"])
                               {
                                   NSDictionary *dictChildrenData=[[NSDictionary alloc]initWithDictionary:[childDict valueForKey:childDictKey]];
                                   objImgSet.thumbnailURL=[NSURL URLWithString:[dictChildrenData valueForKey:@"thumbnail"]];
                                   objImgSet.imageSourceURL=[NSURL URLWithString:[dictChildrenData valueForKey:@"url"]];
                                   NSDictionary *dictImage=[dictChildrenData valueForKey:@"preview"];
                                   NSArray *arrImageData=[dictImage valueForKey:@"images"];
                                   for(NSDictionary *imageDict in arrImageData)
                                   {
                                       for(NSString *str in imageDict.allKeys)
                                       {
                                           if([str isEqualToString:@"source"])
                                           {
                                               RWImageDetail *objImgDetail=[[RWImageDetail alloc]init];
                                               objImgDetail.imageURL=[NSURL URLWithString:[[imageDict valueForKey:str]valueForKey:@"url"]];
                                               objImgDetail.width=[[[imageDict valueForKey:str]valueForKey:@"width"]integerValue];
                                               
                                               objImgDetail.height=[[[imageDict valueForKey:str]valueForKey:@"height"]integerValue];
                                               objImgSet.sourceImage=objImgDetail;
                                               
                                               
                                           }
                                           else if([str isEqualToString:@"resolutions"])
                                           {
                                               NSArray *arrResolutions=[NSArray arrayWithArray:[imageDict valueForKey:str]];
                                               NSMutableArray *marrResolutions=[[NSMutableArray alloc]init];
                                               for(NSDictionary *dict in arrResolutions)
                                               {
                                                   
                                                   RWImageDetail *objImgDetail=[[RWImageDetail alloc]init];
                                                   objImgDetail.imageURL=[NSURL URLWithString:[dict valueForKey:@"url"]];
                                                   objImgDetail.width=[[dict valueForKey:@"width"]integerValue];
                                                   
                                                   objImgDetail.height=[[dict valueForKey:@"height"]integerValue];
                                                   [marrResolutions addObject:objImgDetail];
                                                   
                                               }
                                               objImgSet.marrResolutions=marrResolutions;
                                           }
                                           else if([str isEqualToString:@"id"])
                                           {
                                               
                                               objImgSet.imageID=[imageDict valueForKey:str];
                                               
                                           }
                                           
    
                                       }
                                 }
                                   
                                   
                                   
                                
                               }
                        }
                        [marrImageSet addObject:objImgSet];
                    }
                }
                
            }
        }
    }
    
    arrImageSet=[NSMutableArray arrayWithArray:marrImageSet];
    
    
    
    return arrImageSet;
    
    
}

@end
