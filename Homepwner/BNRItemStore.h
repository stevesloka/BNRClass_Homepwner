//
//  BNRItemStore.h
//  Homepwner
//
//  Created by Steve Sloka on 4/16/13.
//  Copyright (c) 2013 Steve Sloka App Dev. All rights reserved.
//

#import <Foundation/Foundation.h>


@class BNRItem;

@interface BNRItemStore : NSObject

+(BNRItemStore *)sharedStore;

@property (nonatomic, strong, readonly) NSArray *allItems;

-(void)removeItem:(BNRItem *)p;
-(BNRItem *)createItem;

-(void)moveItemAtIndex:(int)from
               toIndex:(int)to;

-(BOOL)saveChanges;

-(NSArray *)allAssetTypes;

@end
