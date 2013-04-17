//
//  BNRItemStore.m
//  Homepwner
//
//  Created by Steve Sloka on 4/16/13.
//  Copyright (c) 2013 Steve Sloka App Dev. All rights reserved.
//

#import "BNRItemStore.h"
#import "BNRItem.h"
#import "BNRImageStore.h"

@interface BNRItemStore()
{
    NSMutableArray *_allItems;
    NSMutableArray *_allAssetTypes;
    NSManagedObjectContext *_context;
    NSManagedObjectModel *_model;
}

-(NSString *)itemArchivePath;
-(void)loadAllItems;

@end


@implementation BNRItemStore

@synthesize allItems = _allItems;

-(id)init
{
    self = [super init];
    if(self) {
        //Read in Homepwner.xcdtamodeld
        _model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
        
        //where does the SQLite file go?
        NSString *path = [self itemArchivePath];
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        
        NSError *error = nil;
        
        if(![psc addPersistentStoreWithType:NSSQLiteStoreType
                              configuration:nil
                                        URL:storeURL
                                    options:nil
                                      error:&error]) {
            
            [NSException raise:@"Open failed" format:@"Reason: %@", [error localizedDescription]];
        }
        
        //Create the managed object context
        _context = [[NSManagedObjectContext alloc] init];
        [_context setPersistentStoreCoordinator:psc];
        
        //The managed object context can manage undo, but we don't need it
        [_context setUndoManager:nil];
        
        [self loadAllItems];
    }
    
    return self;
}

+ (BNRItemStore *)sharedStore
{
    
    static BNRItemStore *sharedStore = nil;
    if(!sharedStore)
        sharedStore = [[super allocWithZone:nil] init];
    
    return sharedStore;
}

+(id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

-(void)removeItem:(BNRItem *)p
{
    NSString *key = [p imageKey];
    [[BNRImageStore sharedStore] deleteImageForKey:key];
    [_context deleteObject:p];
    [_allItems removeObjectIdenticalTo:p];
}

-(BNRItem *)createItem
{
    double order;
    if([_allItems count] == 0) {
        order = 1.0;
    } else {
        order = [[_allItems lastObject] orderingValue] + 1.0;
    }
    
    NSLog(@"Adding after %d items, order = %.2f", [_allItems count], order);
    
    BNRItem *p = [NSEntityDescription insertNewObjectForEntityForName:@"BNRItem" inManagedObjectContext:_context];
    
    [p setOrderingValue:order];
    
    [_allItems addObject:p];
    
    return p;
}

-(void)moveItemAtIndex:(int)from toIndex:(int)to
{
    if(from == to) {
        return;
    }
    
    //Get pointer to object being moved so we can re-inssert it
    BNRItem *p = [_allItems objectAtIndex:from];
    
    //Remove p from array
    [_allItems removeObjectAtIndex:from];
    
    // Insert p in array at new location
    [_allItems insertObject:p atIndex:to];
    
    //Computing a new orderValue for the object that was moved
    double lowerBound = 0.0;
    
    //Is there an object before it was in the array?
    if(to > 0) {
        lowerBound = [[_allItems objectAtIndex:to - 1] orderingValue];
    } else {
        lowerBound = [[_allItems objectAtIndex:1] orderingValue] -2.0;
    }
    
    double upperBound = 0.0;
    
    // Is there an object after it in the array?
    if(to < [_allItems count] -1) {
        upperBound = [[_allItems objectAtIndex:to + 1] orderingValue];
    } else {
        upperBound = [[_allItems objectAtIndex:to -1] orderingValue] + 2.0;
    }
    
    double newOrderValue = (lowerBound + upperBound) / 2.0;
    
    NSLog(@"moving to order %f", newOrderValue);
    [p setOrderingValue:newOrderValue];
}

-(NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                       NSUserDomainMask,
                                                                       YES);
    
    //Get one and only one document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}

-(BOOL)saveChanges
{
    NSError *err = nil;
    BOOL successful = [_context save:&err];
    if(!successful) {
        NSLog(@"Error saving: %@", [err localizedDescription]);
    }
    
    return successful;
}

-(void)loadAllItems
{
    if(!_allItems) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [[_model entitiesByName] objectForKey:@"BNRItem"];
        [request setEntity:e];
        
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue" ascending:YES];
        [request setSortDescriptors:@[sd]];
        
        NSError *error;
        NSArray *result = [_context executeFetchRequest:request error:&error];
        
        if(!result) {
            [NSException raise:@"Fetch failed" format:@"Reason: %@", [error localizedDescription]];
        }
        
        _allItems = [[NSMutableArray alloc] initWithArray:result];
    }
}

-(NSArray *)allAssetTypes
{
    if(!_allAssetTypes) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [[_model entitiesByName] objectForKey:@"BNRAssetType"];
        
        [request setEntity:e];
        
        NSError *error;
        NSArray *result = [_context executeFetchRequest:request error:&error];
        
        if(!result) {
            [NSException raise:@"Fetch Failed" format:@"Reason: %@", [error localizedDescription]];
        }
        
        _allAssetTypes = [result mutableCopy];
    }
    
    //Is this the first time the program is being run?
    if([_allAssetTypes count] == 0) {
        NSManagedObject *type;
        
        type = [NSEntityDescription insertNewObjectForEntityForName:@"BNRAssetType" inManagedObjectContext:_context];
        [type setValue:@"Furniture" forKey:@"label"];
        [_allAssetTypes addObject:type];
        
        type = [NSEntityDescription insertNewObjectForEntityForName:@"BNRAssetType" inManagedObjectContext:_context];
        [type setValue:@"Jewelry" forKey:@"label"];
        [_allAssetTypes addObject:type];
        
        type = [NSEntityDescription insertNewObjectForEntityForName:@"BNRAssetType" inManagedObjectContext:_context];
        [type setValue:@"Electronics" forKey:@"label"];
        [_allAssetTypes addObject:type];
    }
    
    return _allAssetTypes;
}

@end
