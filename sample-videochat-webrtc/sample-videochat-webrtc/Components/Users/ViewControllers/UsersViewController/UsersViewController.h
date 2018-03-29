//
//  UsersViewController.h
//  LoginComponent
//
//  Created by Andrey Ivanov on 02/06/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UsersDataSource.h"

@interface UsersViewController : UITableViewController

@property (strong, nonatomic) UsersDataSource *dataSource;

@end
