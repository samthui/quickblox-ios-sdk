//
//  LoginTableViewController.h
//  LoginComponent
//
//  Created by Andrey Ivanov on 01/06/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginTableViewController : UITableViewController

//-(void)signupUser:(NSString *)fullname type:(NSString *)type paid:(BOOL)isPaid;
- (void)updateFieldsName:(NSString *)fullname type:(NSString *)type paid:(BOOL)isPaid;

@end
