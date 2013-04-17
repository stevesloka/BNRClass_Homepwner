//
//  BNRItem.h
//  Homepwner
//
//  Created by Steve Sloka on 4/17/13.
//  Copyright (c) 2013 Steve Sloka App Dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BNRItem : NSManagedObject

@property (nonatomic, retain) NSString * itemName;
@property (nonatomic, retain) NSString * serialNumber;
@property (nonatomic) int32_t valueInDollars;
@property (nonatomic) NSTimeInterval dateCreated;
@property (nonatomic, strong) NSString *imageKey;
@property (nonatomic, retain) NSData * thumbnailData;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic) double orderingValue;
@property (nonatomic, retain) NSManagedObject *assetType;

-(void)setThumbnailDataFromImage:(UIImage *)image;

@end
