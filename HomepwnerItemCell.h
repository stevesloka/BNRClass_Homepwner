//
//  HomepwnerItemCell.h
//  Homepwner
//
//  Created by Steve Sloka on 4/17/13.
//  Copyright (c) 2013 Steve Sloka App Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomepwnerItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@property (weak, nonatomic) id controller;
@property (weak, nonatomic) UITableView *owningTableView;

@end
