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
#import "RegisterTableViewController.h"
#import "QBCore.h"
#import "SVProgressHUD.h"

#import "AFURLRequestSerialization.h"
#import "AFURLResponseSerialization.h"
#import "AFHTTPSessionManager.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

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
    
    self.navigationItem.title = NSLocalizedString(@"", nil);
    
    [self defaultConfiguration];
    //Update interface and start login if user exist
//    if (Core.currentUser) {
//
//        self.userNameTextField.text = Core.currentUser.fullName;
//        self.chatRoomNameTextField.text = Core.currentUser.password;//[Core.currentUser.tags firstObject];
//        [self login];
//    }
    
    if (Core.currentUser) {
        [self beginConnect];
        [Core loginWithCurrentUser];
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
//            NSLog(@"success! data=%@",responseObject);
            
            if ([[responseObject objectForKey:@"isLogin"] intValue] == 1) {
                
                NSString *fullName = [responseObject objectForKey:@"fullname"];
                NSString *userType = [responseObject objectForKey:@"user_type"];
                BOOL isPaid = [[responseObject objectForKey:@"paid"] boolValue];
                
                [self signupUser:fullName type:userType paid:isPaid];
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
            
//            NSLog(@"Errors=%@", [error description]);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error  description]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }];
    }
}

- (void)startSignUpNewUser:(QBUUser *)newUser isPaid:(BOOL)isPaid {
    
    [SVProgressHUD showWithStatus:@"Đang tạo mới..."];
    
    [QBRequest signUp:newUser
         successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user)
     {
         
         [SVProgressHUD dismiss];
         user.password = @"x6Bt0VDy5";
         [Core didLoginWithUser:user isPaid:isPaid];
         [self performSegueWithIdentifier:@"ShowUsersViewController" sender:nil];
     } errorBlock:^(QBResponse * _Nonnull response) {
         
        [SVProgressHUD dismiss];

//        NSLog(@"Errors=%@", [response.error description]);

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[response.error  description]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
     }];
}

- (QBUUser *)createUserWithEnteredData:(NSString *)type_user data:(NSString *)custom_data {
    if ([type_user isEqualToString:@"doctor"] || [type_user isEqualToString:@"clinic"]) {
//        return createQBUserWithCurrentData(String.valueOf(userNameEditText.getText()), "doctor", custom_data);
        return [self createQBUserWithCurrentData:self.userNameTextField.text chatroom:@"doctor" data:custom_data];
    }
//    return createQBUserWithCurrentData(String.valueOf(userNameEditText.getText()), "user", custom_data);
    return [self createQBUserWithCurrentData:self.userNameTextField.text chatroom:@"user" data:custom_data];
}

- (QBUUser *)createQBUserWithCurrentData:(NSString *)userName chatroom:(NSString *)chatRoomName data:(NSString *)custom_data {
//    QBUUser *qbUser = null;
//    if (!TextUtils.isEmpty(userName) && !TextUtils.isEmpty(chatRoomName)) {
//        StringifyArrayList<String> userTags = new StringifyArrayList<>();
//        userTags.add(chatRoomName);
//
//        qbUser = new QBUser();
//        qbUser.setFullName(userName);
//        qbUser.setCustomData(custom_data);
//        qbUser.setLogin(getCurrentDeviceId());
//        qbUser.setPassword(Consts.DEFAULT_USER_PASSWORD);
//        qbUser.setTags(userTags);
//    }
    
    
    QBUUser *qbUser = [QBUUser user];
    
    qbUser.login = [NSUUID UUID].UUIDString;
    qbUser.fullName = userName;
    qbUser.customData = custom_data;
    qbUser.tags = @[chatRoomName].mutableCopy;
    qbUser.password = @"x6Bt0VDy5";
    
    return qbUser;
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

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if ([segue.destinationViewController isKindOfClass:[RegisterTableViewController class]]) {
         RegisterTableViewController *registerTableVC = (RegisterTableViewController *)segue.destinationViewController;
         registerTableVC.loginTableViewController = self;
     }
 }

#pragma mark - public methods
- (void)signupUser:(NSString *)fullname type:(NSString *)type paid:(BOOL)isPaid {
    QBUUser *qbUser = [self createUserWithEnteredData:type data:fullname];
    [self startSignUpNewUser:qbUser isPaid:isPaid];
}

- (void)updateFieldsName:(NSString *)fullname type:(NSString *)type paid:(BOOL)isPaid {
    // Assign UI
    self.userNameTextField.text = fullname;
    
    //
    [self signupUser:fullname type:type paid:isPaid];
}

@end
