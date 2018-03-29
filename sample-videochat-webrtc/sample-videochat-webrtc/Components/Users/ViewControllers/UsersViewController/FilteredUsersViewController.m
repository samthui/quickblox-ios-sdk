//
//  FilteredUsersViewController.m
//  BacSiViet
//
//  Created by Smisy on 3/24/18.
//  Copyright © 2018 QuickBlox Team. All rights reserved.
//

#import "FilteredUsersViewController.h"
#import "UserIconTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

NSString *const kCellIdentifier = @"UserIconCellIdentifier";
NSString *const kTableCellNibName = @"FilteredUserCell";

@interface FilteredUsersViewController () <UITableViewDataSource>

@end

@implementation FilteredUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // we use a nib which contains the cell's view and this class as the files owner
    [self.tableView registerNib:[UINib nibWithNibName:kTableCellNibName bundle:nil] forCellReuseIdentifier:kCellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.filteredUsers.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserIconTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    QBUUser *user = self.filteredUsers[indexPath.row];
    
    NSArray *parseUrlArray = [user.customData componentsSeparatedByString:@"-_-"];
    // Avatar
    if (parseUrlArray.count > 1) {
        NSString *avatarUrl = [parseUrlArray lastObject];
        if (![avatarUrl containsString:@"http://"]) {
            avatarUrl = [NSString stringWithFormat:@"http://%@", avatarUrl];
        }
        [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrl]
                                placeholderImage:[UIImage imageNamed:@"icon"]];
    } else {
        cell.avatarImageView.image = [UIImage imageNamed:@"icon"];
    }
    
    // Info
    NSString *name = @"";
    NSString *detail = @"";
    
    NSString *customData = [parseUrlArray firstObject];
    NSArray *array = [customData componentsSeparatedByString:@"-"];
    if (array.count > 0) {
        name = [array firstObject];
    }
    if (array.count > 1) {
        detail = [array objectAtIndex:1];
    }
    
    cell.nameLabel.text = name;
    cell.emailLabel.text = detail;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
