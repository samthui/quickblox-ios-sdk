//
//  SwitchItemModel.m
//  BacSiViet
//
//  Created by Andrey Ivanov on 30/09/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "SwitchItemModel.h"
#import "SettingSwitchCell.h"

@implementation SwitchItemModel

- (Class)viewClass {
    
    return [SettingSwitchCell class];
}

@end
