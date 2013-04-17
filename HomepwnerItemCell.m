//
//  HomepwnerItemCell.m
//  Homepwner
//
//  Created by Steve Sloka on 4/17/13.
//  Copyright (c) 2013 Steve Sloka App Dev. All rights reserved.
//

#import "HomepwnerItemCell.h"

@implementation HomepwnerItemCell

-(void)awakeFromNib
{
    //Remove any automatic contrains from the views
    for(UIView *v in [[self contentView] subviews]) {
        [v setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    
    
    //Name all the views for the visual format string
    NSDictionary *names = @{
                            @"image": [self thumbnailView],
                            @"name": [self nameLabel],
                            @"value": [self valueLabel],
                            @"serial": [self serialNumberLabel]
                            };
    
    //Create a horizontal visual format string
    NSString *fmt = @"H:|-2-[image(==40)]-[name]-[value(==42)]-|";
    
    //Create the constraints from this visual format string
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:fmt options:0 metrics:nil views:names];
    
    //Add the constraints to teh content view, which is the superview for all the cell's content
    [[self contentView] addConstraints:constraints];
    
    fmt = @"V:|-1-[name(==20)]-(>=0)-[serial(==20)]-1-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:fmt options:NSLayoutFormatAlignAllLeft metrics:nil views:names];
    
    [[self contentView] addConstraints:constraints];
    
    NSArray * (^constraintBuilder)(UIView *, float);
    constraintBuilder = ^(UIView *view, float height) {
        return @[
                 //Constraint 0: Center Y of incoming view to contentView
                 [NSLayoutConstraint constraintWithItem:view
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:[self contentView]
                                              attribute:NSLayoutAttributeCenterY
                                             multiplier:1.0
                                               constant:0],
                 //Constraint 1: Pin width of incoming view to constant height
                 [NSLayoutConstraint constraintWithItem:view
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:0.0
                                               constant:height]
                 ];
    };

    constraints = constraintBuilder([self thumbnailView], 40);
    [[self contentView] addConstraints:constraints];
    
    constraints = constraintBuilder([self valueLabel], 21);
    [[self contentView] addConstraints:constraints];
    
    //Create transparent button, give it to target-action pair, add it to contentView
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [button addTarget:self action:@selector(showImage) forControlEvents:UIControlEventTouchUpInside];
    
    [[self contentView] addSubview:button];
    
    //Configure the names dictionary and format string to apply contraints
    names = @{
              @"button": button,
              @"image" : [self thumbnailView],
              @"name": [self nameLabel]
              };
    
    fmt = @"H:|-2-[button(==image)]-[name]";
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:fmt options:0 metrics:nil views:names];
    
    [[self contentView] addConstraints:constraints];
    
    [[self contentView] addConstraints:constraintBuilder(button, 40)];
    
}

-(void)showImage:(id)sender
{
    NSString *selector = NSStringFromSelector(_cmd);
    selector = [selector stringByAppendingString:@"atIndexPath"];
    
    SEL newSelector = NSSelectorFromString(selector);
    
    NSIndexPath *indexPath = [[self owningTableView] indexPathForCell:self];
    
    if(indexPath) {
        if([[self controller] respondsToSelector:newSelector]) {
            [[self controller] performSelector:newSelector withObject:sender withObject:indexPath];
        }
    }
    

}

@end
