//
//  RegisterTableViewController.m
//  BacSiViet
//
//  Created by Smisy on 3/29/18.
//  Copyright © 2018 QuickBlox Team. All rights reserved.
//

#import "RegisterTableViewController.h"
#import "QBLoadingButton.h"

@interface RegisterTableViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet QBLoadingButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *registerInfo;

@end

@implementation RegisterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.delaysContentTouches = NO;
    
    self.navigationItem.title = NSLocalizedString(@"Đăng ký", nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewAutomaticDimension;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self validateTextField:textField];
}

- (IBAction)editingChanged:(UITextField *)sender {
    
    [self validateTextField:sender];
    self.registerButton.enabled = [self userNameIsValid] && [self passwordIsValid];
}

- (void)validateTextField:(UITextField *)textField {
    
    if (textField == self.userNameTextField && ![self userNameIsValid]) {
        
//        self.chatRoomDescritptionLabel.text = @"";
//        self.userNameDescriptionLabel.text =
//        NSLocalizedString(@"Field should contain alphanumeric characters only in a range 3 to 20. The first character must be a letter.", nil);
        [self setRegisterInfoText:@"Tên tài khoản không hợp lệ."];
    }
    else if (textField == self.passwordTextField && ![self passwordIsValid]) {
        
//        self.userNameDescriptionLabel.text = @"";
//        self.chatRoomDescritptionLabel.text =
//        NSLocalizedString(@"Field should contain alphanumeric characters only in a range 3 to 15, without space. The first character must be a letter.", nil);
        [self setRegisterInfoText:@"Mật khẩu không hợp lệ."];
    }
    else {
        
//        self.chatRoomDescritptionLabel.text = self.userNameDescriptionLabel.text = @"";
        [self setRegisterInfoText:@""];
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)setRegisterInfoText:(NSString *)text {
    
    if (![text isEqualToString:self.registerInfo.text]) {
        
        self.registerInfo.text = text;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

#pragma mark - Validation helpers

- (BOOL)userNameIsValid {
    BOOL isValid = false;
    
    if (self.userNameTextField.text && ![[self.userNameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        isValid = true;
    }
    
    return isValid;
}

- (BOOL)passwordIsValid {
    BOOL isValid = false;
    
    if (self.passwordTextField.text && [self.passwordTextField.text length] > 0) {
        isValid = true;
    }
    
    return isValid;
}

@end
