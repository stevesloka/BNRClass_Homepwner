//
//  BNRImageStore.h
//  Homepwner
//
//  Created by Steve Sloka on 4/16/13.
//  Copyright (c) 2013 Steve Sloka App Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BNRImageStore : NSObject

+(BNRImageStore *)sharedStore;

-(void)setImage:(UIImage *)i forKey:(NSString *)s;
-(UIImage *)imageForKey:(NSString *)s;
-(void)deleteImageForKey:(NSString *)s;

@end
