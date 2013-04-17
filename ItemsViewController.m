//
//  ItemsViewController.m
//  Homepwner
//
//  Created by Steve Sloka on 4/16/13.
//  Copyright (c) 2013 Steve Sloka App Dev. All rights reserved.
//

#import "ItemsViewController.h"
#import "BNRItemStore.h"
#import "BNRItem.h"

@interface ItemsViewController()
{
    


}

-(IBAction)addNewItem:(id)sender;


@end

@implementation ItemsViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"HomepwnerItemCell" bundle:nil];
    
    //Register this NIB which contains the cell
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"HomepwnerItemCell"];
}


-(IBAction)addNewItem:(id)sender
{
    //Create a new BNRItem and add it to the store
    BNRItem *newItem = [[BNRItemStore sharedStore] createItem];
    
    //Figure out where that item is in the array
    int lastRow = [[[BNRItemStore sharedStore] allItems] indexOfObject:newItem];

    NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
    
    //Insert this row into the table
    [[self tableView] insertRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationTop];
}

-(id)init
{
    //Call the superclass's designted initializer
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if(self) {
        UINavigationItem *n = [self navigationItem];
        
        [n setTitle: @"Homepwner"];
        
        //Create a new bar button item that will send
        //addNewItem: to ItemsViewController
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
        
        //Set this bar button item as the right item in the navigationItem
        [[self navigationItem] setRightBarButtonItem:bbi];
        
        [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
    }
    
    return self;
}

-(id)initWithStyle:(UITableViewStyle)Style
{
    return [self init];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[BNRItemStore sharedStore] allItems] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BNRItem *p = [[[BNRItemStore sharedStore] allItems] objectAtIndex:[indexPath row]];
    
    //Get the new or recycled cell
    HomepwnerItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomepwnerItemCell"];
    
    //Configure the cell with the BNRItem
    [cell setController:self];
    [cell setOwningTableView:tableView];
    
    [[cell nameLabel] setText:[p itemName]];
    [[cell serialNumberLabel] setText:[p serialNumber]];
    [[cell valueLabel] setText:[NSString stringWithFormat:@"$%d", [p valueInDollars]]];
    
    [[cell thumbnailView] setImage:[p thumbnail]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //If the table view is asking to commit a delete command...
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        BNRItemStore *ps = [BNRItemStore sharedStore];
        NSArray *items = [ps allItems];
        BNRItem *p = [items objectAtIndex:[indexPath row]];
        [ps removeItem:p];
        
        //We also remove that row from the table view with animation
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[BNRItemStore sharedStore] moveItemAtIndex:[sourceIndexPath row] toIndex:[destinationIndexPath row]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    
    NSArray *items = [[BNRItemStore sharedStore] allItems];
    BNRItem *selectedItem = [items objectAtIndex:[indexPath row]];
    
    //Give detail view controller a pointer to the item object in row
    [detailViewController setItem:selectedItem];
    
    //Push it onto the top of the navigation controller's stack
    [[self navigationController] pushViewController:detailViewController animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
}

-(void)showImage:(id)sender atIndexPath:(NSIndexPath *)ip
{
    NSLog(@"Going to show the image for %@", ip);
}

@end
