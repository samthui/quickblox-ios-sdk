//
//  UsersDataSource.m
//  LoginComponent
//
//  Created by Andrey Ivanov on 06/06/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "UsersDataSource.h"
#import "UserTableViewCell.h"
#import "UserIconTableViewCell.h"
#import <Quickblox/Quickblox.h>
#import "QBProfile.h"
#import "PlaceholderGenerator.h"

@interface UsersDataSource() {
    
    NSMutableSet <QBUUser *> *_usersSet;
    NSMutableArray <QBUUser *> *_selectedUsers;
    QBUUser *_currentUser;
}

@end

@implementation UsersDataSource

- (instancetype)initWithCurrentUser:(QBUUser *)currentUser {
    
    self = [super init];
    if (self) {
        
        _currentUser = currentUser;
        _usersSet = [NSMutableSet set];
        _selectedUsers = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark - Public methods

- (BOOL)setUsers:(NSArray *)users {
    
    NSSet *usersSet = [NSSet setWithArray:users];
    
    for (QBUUser *user in users) {
        user.fullName = user.fullName ?: [NSString stringWithFormat:@"User id: %tu (no full name)", user.ID];
    }
    
    if (![_usersSet isEqualToSet:usersSet]) {
        
        [_usersSet removeAllObjects];
        [_usersSet unionSet:usersSet];
        
        for (QBUUser *user in self.selectedUsers) {
            
            if (![_usersSet containsObject:user]) {
                [_selectedUsers removeObject:user];
            }
        }
        
        return YES;
    }
    
    return NO;
}

- (NSArray<QBUUser *> *)selectedUsers {
    
    return [_selectedUsers copy];
}

- (void)selectUserAtIndexPath:(NSIndexPath *)indexPath {
    
    QBUUser *user = self.usersSortedByLastSeen[indexPath.row];
    
    if ([_selectedUsers containsObject:user]) {
        [_selectedUsers removeObject:user];
    }
    else {
        [_selectedUsers addObject:user];
    }
}

- (QBUUser *)userWithID:(NSUInteger)ID {
    
    for (QBUUser *user in _usersSet) {
        
        if (user.ID == ID) {
            return user;
        }
    }
    
    return nil;
}

- (NSArray <NSNumber *> *)idsForUsers:(NSArray <QBUUser *>*)users {
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:users.count];
    
    for (QBUUser *user in users) {
        [result addObject:@(user.ID)];
    }
    
    return result;
}

- (void)removeAllUsers {
    
    [_usersSet removeAllObjects];
}

- (NSArray <QBUUser *> *)usersSortedByFullName {
    
    return [self sortUsersBySEL:@selector(fullName)];
}

- (NSArray <QBUUser *> *)usersSortedByLastSeen {
    
    return [self sortUsersBySEL:@selector(createdAt)];
}

- (NSArray <QBUUser *> *)sortUsersBySEL:(SEL)selector {
    
    // Create sort Descriptor
    NSSortDescriptor *usersSortDescriptor =
    [[NSSortDescriptor alloc] initWithKey:NSStringFromSelector(selector)
                                ascending:NO];
    
    NSArray *sortedUsers = [[self unsortedUsersWithoutMe] sortedArrayUsingDescriptors:@[usersSortDescriptor]];
    
    return sortedUsers;
}

- (NSArray <QBUUser *>*)unsortedUsersWithoutMe {
    
    NSMutableArray *unsorterUsers = [_usersSet.allObjects mutableCopy];
    [unsorterUsers removeObject:_currentUser];
    
    return [unsorterUsers copy];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.usersSortedByLastSeen.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserIconTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserIconCellIdentifier" forIndexPath:indexPath];
    
    QBUUser *user = self.usersSortedByLastSeen[indexPath.row];
    
    // Avatar
    NSArray *parseUrlArray = [user.customData componentsSeparatedByString:@"-_-"];
    if (parseUrlArray.count > 1) {
        NSString *avatarUrl = [parseUrlArray lastObject];
        if (![avatarUrl containsString:@"http://"]) {
            avatarUrl = [NSString stringWithFormat:@"http://%@", avatarUrl];
        }
        NSLog(@"avatarUrl = %@", avatarUrl);
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: avatarUrl]];
            if ( data == nil )
                return;
            dispatch_async(dispatch_get_main_queue(), ^{
                // WARNING: is the cell still using the same data by this point??
                cell.avatarImageView.image = [UIImage imageWithData: data];
            });
        });
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
        detail = [customData substringFromIndex:[name length] + 1];
    }
    
    cell.nameLabel.text = name;
    cell.emailLabel.text = detail;
    
    return cell;
}

- (QBUUser *)userAtIndexPath:(NSIndexPath *)indexPath {
    
    QBUUser *user = self.usersSortedByLastSeen[indexPath.row];
    
    return user;
}

@end
