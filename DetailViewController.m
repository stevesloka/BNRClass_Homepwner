//
//  DetailViewController.m
//  Homepwner
//
//  Created by Steve Sloka on 4/16/13.
//  Copyright (c) 2013 Steve Sloka App Dev. All rights reserved.
//

#import "DetailViewController.h"
#import "BNRItem.h"
#import "BNRImageStore.h"

@interface DetailViewController ()
{
    UIPopoverController *_imagePickerPopover;
}

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *serialNumberField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)takePicture:(id)sender;

@end

@implementation DetailViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BNRItem *item = [self item];
    [[self nameField] setText:[item itemName]];
    [[self serialNumberField] setText:[item serialNumber]];
    [[self valueField] setText:[NSString stringWithFormat:@"%d", [item valueInDollars]]];
    
    //Create a NSDateFormatter that will turn a date into a simple date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    //Use filtered NSDate object to set dateLabel contents
    [[self dateLabel] setText:[dateFormatter stringFromDate:[item dateCreated]]];
    
    NSString *imageKey = [[self item] imageKey];
    
    if(imageKey) {
        UIImage *imageToDisplay = [[BNRImageStore sharedStore] imageForKey:imageKey];
        
        [[self imageView] setImage:imageToDisplay];
        
    } else {
        [[self imageView] setImage:nil];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //Clear first responder
    [[self view] endEditing:YES];
    
    //"Save" the changes to item
    BNRItem *item = [self item];
    [item setItemName:[[self nameField] text]];
    [item setSerialNumber:[[self serialNumberField] text]];
    [item setValueInDollars:[[[self valueField] text] intValue]];
}

-(void)setItem:(BNRItem *)item
{
    _item = item;
    [[self navigationItem] setTitle:[[self item] itemName]];
}

- (IBAction)takePicture:(id)sender {
    
    if([_imagePickerPopover isPopoverVisible]) {
        [_imagePickerPopover dismissPopoverAnimated:YES];
        _imagePickerPopover = nil;
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    //If our device has a camera, we want to take a picture, otherwise we want to pick from the photo library
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else{
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [imagePicker setDelegate:self];
    
    //Place an image picker on the screen
    //Check ipad deice before instantiating the popover controller
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //Create a new popover controller that will display the imagePicker
        _imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        
        [_imagePickerPopover setDelegate:self];
        
        //Display the popover controller; sender is the camera bar button item
        [_imagePickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    } else {
        [self presentViewController: imagePicker animated:YES completion:nil];
    }
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //Get picked image from info dictionary
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString *key = [uuid UUIDString];
    
    [[self item] setImageKey:key];
    
    [[BNRImageStore sharedStore] setImage:image forKey:[[self item] imageKey]];
    
    //Put that image onto the screen in our image view
    [[self imageView] setImage:image];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [_imagePickerPopover dismissPopoverAnimated:YES];
        _imagePickerPopover = nil;
    }
    
    
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    NSLog(@"User dismissed popover");
    _imagePickerPopover = nil;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *iv = [[UIImageView alloc] initWithImage:nil];
    [iv setContentMode:UIViewContentModeScaleAspectFit];
    [iv setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[self view] addSubview:iv];
    [self setImageView:iv];
    
    NSDictionary *nameMap = @{@"imageView" : [self imageView]};
    
    NSArray *horizontalContraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]-0-|" options:0 metrics:nil views:nameMap];
    
    [[self view] addConstraints:horizontalContraints];
    
    /*nameMap = @{@"imageView" : [self imageView],
                @"dateLabel" : [self dateLabel],
                @"toolbar" : [self toolbar]};*/
    
    
}

@end
