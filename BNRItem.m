//
//  BNRItem.m
//  Homepwner
//
//  Created by Steve Sloka on 4/17/13.
//  Copyright (c) 2013 Steve Sloka App Dev. All rights reserved.
//

#import "BNRItem.h"


@implementation BNRItem

@dynamic itemName;
@dynamic serialNumber;
@dynamic valueInDollars;
@dynamic dateCreated;
@dynamic imageKey;
@dynamic thumbnailData;
@dynamic thumbnail;
@dynamic orderingValue;
@dynamic assetType;

-(void)awakeFromFetch
{
    [super awakeFromFetch];
    
    UIImage *tn = [UIImage imageWithData:[self thumbnailData]];
    [self setPrimitiveValue:tn forKey:@"thumbnail"];
}

-(void)awakeFromInsert
{
    [super awakeFromInsert];
    NSTimeInterval t = [[NSDate date] timeIntervalSinceReferenceDate];
    [self setDateCreated:t];
}

-(void)setThumbnailDataFromImage:(UIImage *)image
{
    CGSize origImageSize = [image size];
    
    //The rectangle of the thumbnail
    CGRect newRect = CGRectMake(0, 0, 40, 40);
    
    //Figure out a scaling ration to make sure we maintain the same aspect ratio
    float ratio = MAX(newRect.size.width / origImageSize.width, newRect.size.height / origImageSize.height);
    
    //Create a transparent bitmap context with a scaling factor equal to that of the screen
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    
    //Create a path that is a rounded rectangle
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:5.0];
    
    //Make all subsequent drawing clips to this rounded rectangle
    [path addClip];
    
    //center the image in the thumbnail rectangle
    CGRect projectRect;
    projectRect.size.width = ratio * origImageSize.width;
    projectRect.size.height = ratio * origImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
    
    //Draw the image on it
    [image drawInRect:projectRect];
    
    //Get the image from the image context, keep it as our thumbnail
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    [self setThumbnail:smallImage];
    
    //Get the PNG representation of the image and set it as our archivable data
    NSData *data = UIImagePNGRepresentation(smallImage);
    [self setThumbnailData:data];
    
    //Cleanup image context resources, we're done
    UIGraphicsEndImageContext();
}


@end
