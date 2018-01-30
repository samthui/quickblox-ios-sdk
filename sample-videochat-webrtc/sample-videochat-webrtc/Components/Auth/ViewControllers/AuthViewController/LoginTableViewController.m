//
//  LoginTableViewController.m
//  LoginComponent
//
//  Created by Andrey Ivanov on 01/06/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Quickblox/Quickblox.h>
#import "LoginTableViewController.h"
#import "QBLoadingButton.h"
#import "UsersViewController.h"
#import "QBCore.h"
#import "SVProgressHUD.h"

#import "AFURLRequestSerialization.h"
#import "AFURLResponseSerialization.h"
#import "AFHTTPSessionManager.h"

@interface LoginTableViewController () <UITextFieldDelegate, QBCoreDelegate>

@property (weak, nonatomic) IBOutlet UILabel *loginInfo;
@property (weak, nonatomic) IBOutlet UILabel *userNameDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *chatRoomDescritptionLabel;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *chatRoomNameTextField;
@property (weak, nonatomic) IBOutlet QBLoadingButton *loginButton;

@property (assign, nonatomic) BOOL needReconnect;

@end

@implementation LoginTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Core addDelegate:self];
    
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.delaysContentTouches = NO;
    
    self.navigationItem.title = NSLocalizedString(@"Enter to chat", nil);
    
    [self defaultConfiguration];
    //Update interface and start login if user exist
    if (Core.currentUser) {
        
        self.userNameTextField.text = Core.currentUser.fullName;
        self.chatRoomNameTextField.text = [Core.currentUser.tags firstObject];
        [self login];
    }
}

- (void)defaultConfiguration {
    
    [self.loginButton hideLoading];
    [self.loginButton setTitle:NSLocalizedString(@"Login", nil)
                      forState:UIControlStateNormal];
    
    self.loginButton.enabled = NO;
    self.userNameTextField.text = @"";
    self.chatRoomNameTextField.text = @"";
    
    [self setInputEnabled:YES];
    // Reachability
    void (^updateLoginInfo)(QBNetworkStatus status) = ^(QBNetworkStatus status) {
        
        NSString *loginInfo = (status == QBNetworkStatusNotReachable) ?
        NSLocalizedString(@"Please check your Internet connection", nil):
        NSLocalizedString(@"Hãy nhập tên đăng nhập và mật khẩu mà bạn đã đăng ký trên website bacsiviet.vn.", nil);
        [self setLoginInfoText:loginInfo];
    };
    
    Core.networkStatusBlock = ^(QBNetworkStatus status) {
        
        if (self.needReconnect && status != QBNetworkStatusNotReachable) {
            
            self.needReconnect = NO;
            [self login];
        }
        else {
            
            updateLoginInfo(status);
        }
    };
    
    updateLoginInfo(Core.networkStatus);
}

#pragma mark - Disable / Enable inputs

- (void)setInputEnabled:(BOOL)enabled {
    
    self.chatRoomNameTextField.enabled = enabled;
    self.userNameTextField.enabled = enabled;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewAutomaticDimension;
}

#pragma mark - UIControl Actions

- (IBAction)didPressLoginButton:(QBLoadingButton *)sender {
    
    [self login];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self validateTextField:textField];
}

- (IBAction)editingChanged:(UITextField *)sender {
    
    [self validateTextField:sender];
    self.loginButton.enabled = [self userNameIsValid] && [self chatRoomIsValid];
}

- (void)validateTextField:(UITextField *)textField {
    
    if (textField == self.userNameTextField && ![self userNameIsValid]) {
        
        self.chatRoomDescritptionLabel.text = @"";
        self.userNameDescriptionLabel.text =
        NSLocalizedString(@"Field should contain alphanumeric characters only in a range 3 to 20. The first character must be a letter.", nil);
    }
    else if (textField == self.chatRoomNameTextField && ![self chatRoomIsValid]) {
        
        self.userNameDescriptionLabel.text = @"";
        self.chatRoomDescritptionLabel.text =
        NSLocalizedString(@"Field should contain alphanumeric characters only in a range 3 to 15, without space. The first character must be a letter.", nil);
    }
    else {
        
        self.chatRoomDescritptionLabel.text = self.userNameDescriptionLabel.text = @"";
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)setLoginInfoText:(NSString *)text {
    
    if (![text isEqualToString:self.loginInfo.text]) {
        
        self.loginInfo.text = text;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

#pragma mark - Login

/*- (void)login {
    
    [self setEditing:NO];
    [self beginConnect];
    
    if (Core.currentUser) {
        
        [Core loginWithCurrentUser];
    }
    else {
        
        [Core signUpWithFullName:self.userNameTextField.text
                        roomName:self.chatRoomNameTextField.text];
    }
}*/

- (BOOL)isLoginEmpty
{
    BOOL emptyLogin = self.userNameTextField.text.length == 0;
    self.userNameTextField.backgroundColor = emptyLogin ? [UIColor redColor] : [UIColor whiteColor];
    return emptyLogin;
}

- (BOOL)isPasswordEmpty
{
    BOOL emptyPassword = self.chatRoomNameTextField.text.length == 0;
    self.chatRoomNameTextField.backgroundColor = emptyPassword ? [UIColor redColor] : [UIColor whiteColor];
    return emptyPassword;
}

- (void)login
{
    
    [self setEditing:NO];
    [self beginConnect];
    
    
    [self.view endEditing:YES];
    
    BOOL notEmptyLogin = ![self isLoginEmpty];
    BOOL notEmptyPassword = ![self isPasswordEmpty];
    
    if (notEmptyLogin && notEmptyPassword) {
        NSString *login = self.userNameTextField.text;
        NSString *password = self.chatRoomNameTextField.text;
        
        [SVProgressHUD showWithStatus:@"Signing in"];
        
        NSString *url = @"http://bacsiviet.vn/test-mobile";
        NSDictionary *parameters = @{@"email": login, @"pwd": password};
        
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
        [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"success! data=%@",responseObject);
            
            if ([[responseObject objectForKey:@"isLogin"] intValue] == 1) {
                [SVProgressHUD dismiss];
                
                [self performSegueWithIdentifier:@"ShowUsersViewController" sender:nil];
            } else {
                [SVProgressHUD dismiss];
                
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:[responseObject objectForKey:@"msg"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [SVProgressHUD dismiss];
            
            NSLog(@"Errors=%@", [error description]);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error  description]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }];
    }
}

- (void)beginConnect {
    
    [self setInputEnabled:NO];
    [self.loginButton showLoading];
}

- (void)endConnectError:(NSError *)error {
    
    [self setInputEnabled:YES];
    [self.loginButton hideLoading];
}

#pragma mark - QBCoreDelegate

- (void)coreDidLogin:(QBCore *)core {
    if (self.isViewLoaded && self.view.window != nil) {
        // only perform segue if login view controller is visible, otherwise we are already
        // on users view controller screan and this was just a chat connect
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
            [self login];
        }
    }
    
    [self setLoginInfoText:infoText];
}

- (void)core:(QBCore *)core loginStatus:(NSString *)loginStatus {
    
    [self setLoginInfoText:loginStatus];
}

#pragma mark - Validation helpers

- (BOOL)userNameIsValid {
    
//    NSCharacterSet *characterSet = [NSCharacterSet whitespaceCharacterSet];
//    NSString *userName = [self.userNameTextField.text stringByTrimmingCharactersInSet:characterSet];
//    NSString *userNameRegex = @"^[^_][\\w\\u00C0-\\u1FFF\\u2C00-\\uD7FF\\s]{2,19}$";
//    NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", userNameRegex];
//    BOOL userNameIsValid = [userNamePredicate evaluateWithObject:userName];
//
//    return userNameIsValid;
    return YES;
}

- (BOOL)chatRoomIsValid {
    
//    NSCharacterSet *characterSet = [NSCharacterSet whitespaceCharacterSet];
//    NSString *tag = [self.chatRoomNameTextField.text stringByTrimmingCharactersInSet:characterSet];
//    NSString *tagRegex = @"^[a-zA-Z][a-zA-Z0-9]{2,14}$";
//    NSPredicate *tagPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", tagRegex];
//    BOOL tagIsValid = [tagPredicate evaluateWithObject:tag];
//
//    return tagIsValid;
    return YES;
}

@end
