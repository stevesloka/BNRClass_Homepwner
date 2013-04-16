//
//  DetailViewController.h
//  Homepwner
//
//  Created by Steve Sloka on 4/16/13.
//  Copyright (c) 2013 Steve Sloka App Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BNRItem;

@interface DetailViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate> {
    
}

@property (nonatomic, strong) BNRItem *item;

@end
