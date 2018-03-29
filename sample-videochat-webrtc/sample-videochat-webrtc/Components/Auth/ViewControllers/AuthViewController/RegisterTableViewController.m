//
//  RegisterTableViewController.m
//  BacSiViet
//
//  Created by Smisy on 3/29/18.
//  Copyright © 2018 QuickBlox Team. All rights reserved.
//

#import "RegisterTableViewController.h"
#import "QBLoadingButton.h"
#import "QBCore.h"

@interface RegisterTableViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet QBLoadingButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *registerInfo;

@property (assign, nonatomic) BOOL needReconnect;

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
    
    [self defaultConfiguration];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)defaultConfiguration {
    
    [self.registerButton hideLoading];
    [self.registerButton setTitle:NSLocalizedString(@"Đăng ký", nil)
                      forState:UIControlStateNormal];
    
    self.registerButton.enabled = NO;
    self.userNameTextField.text = @"";
    self.passwordTextField.text = @"";
    
    [self setInputEnabled:YES];
    // Reachability
    void (^updateRegisterInfo)(QBNetworkStatus status) = ^(QBNetworkStatus status) {
        
        NSString *registerInfo = (status == QBNetworkStatusNotReachable) ?
        NSLocalizedString(@"Please check your Internet connection", nil):
        NSLocalizedString(@"", nil);
        [self setRegisterInfoText:registerInfo];
    };
    
    Core.networkStatusBlock = ^(QBNetworkStatus status) {
        
        if (self.needReconnect && status != QBNetworkStatusNotReachable) {
            
            self.needReconnect = NO;
//            [self login];
        }
        else {
            
            updateRegisterInfo(status);
        }
    };
    
    updateRegisterInfo(Core.networkStatus);
}

#pragma mark - Disable / Enable inputs

- (void)setInputEnabled:(BOOL)enabled {
    
    self.passwordTextField.enabled = enabled;
    self.userNameTextField.enabled = enabled;
}

#pragma mark - QBCoreDelegate

- (void)coreDidLogin:(QBCore *)core {
    if (self.isViewLoaded && self.view.window != nil) {
        // only perform segue if login view controller is visible, otherwise we are already
        // on users view controller screan and this was just a chat connect
        [SVProgressHUD dismiss];
        
        [self performSegueWithIdentifier:@"ShowUsersViewController" sender:nil];
    }
}

- (void)coreDidLogout:(QBCore *)core {
    
    [self defaultConfiguration];
}

- (void)core:(QBCore *)core error:(NSError *)error domain:(ErrorDomain)domain {
    
    NSString *infoText = error.localizedDescription;
    
    if (error.code == NSURLErrorNotConnectedToInternet) {
        
        infoText = NSLocalizedString(@"Please check your Internet connection", nil);
        self.needReconnect = YES;
    }
    else if (core.networkStatus != QBNetworkStatusNotReachable) {
        
        if (domain == ErrorDomainSignUp || domain == ErrorDomainLogIn) {
//            [self login];
        }
    }
    
    [self setRegisterInfoText:infoText];
}

- (void)core:(QBCore *)core loginStatus:(NSString *)loginStatus {
    
    [self setRegisterInfoText:loginStatus];
}

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
        [self setRegisterInfoText:@"Tên tài khoản không hợp lệ."];
    }
    else if (textField == self.passwordTextField && ![self passwordIsValid]) {
        [self setRegisterInfoText:@"Mật khẩu không hợp lệ."];
    }
    else {
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
