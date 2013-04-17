//
//  BNRImageStore.m
//  Homepwner
//
//  Created by Steve Sloka on 4/16/13.
//  Copyright (c) 2013 Steve Sloka App Dev. All rights reserved.
//

#import "BNRImageStore.h"
#import <CoreData/CoreData.h>

@interface BNRImageStore()
{
    NSMutableDictionary *_dictionary;

}
    -(NSString *)imagePathForKey:(NSString *)key;

@end

@implementation BNRImageStore

+(id)allocWithZone:(NSZone *)zone;
{
    return [self sharedStore];
}

+(BNRImageStore *)sharedStore
{
    static BNRImageStore *sharedStore = nil;
    if(!sharedStore) {
        //Create the singelton
        sharedStore = [[super allocWithZone:NULL] init];
    }
    
    return sharedStore;
}

-(id)init
{
    self = [super init];
    if(self) {
        _dictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(void)setImage:(UIImage *)i forKey:(NSString *)s
{
    [_dictionary setObject:i forKey:s];
    
    //Create full path for image
    NSString *imagePath = [self imagePathForKey:s];
    
    //Turn image into JPEG data
    NSData *d = UIImageJPEGRepresentation(i, 0.5);
    
    //Write it to full path
    [d writeToFile:imagePath atomically:YES];
}

-(UIImage *)imageForKey:(NSString *)s
{
    //if possible, get it from dictionary
    UIImage *result = [_dictionary objectForKey:s];
    
    if(!result) {
        //Create image object from file
        result = [UIImage imageWithContentsOfFile:[self imagePathForKey:s]];
    
        //If we found an image on the file system, place it into the cache
        if(result)
            [_dictionary setObject:result forKey:s];
        else
            NSLog(@"Error: unable to find %@", [self imagePathForKey:s]);
    }
    
    return result;
}

-(void)deleteImageForKey:(NSString *)s
{
    if(!s)
        return;
    
    [_dictionary removeObjectForKey:s];
    
    NSString *path = [self imagePathForKey:s];
    [[NSFileManager defaultManager] removeItemAtPath:path
                                               error:nil];
    
}

-(NSString *)imagePathForKey:(NSString *)key
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                       NSUserDomainMask,
                                                                       YES);
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:key];
}

@end
