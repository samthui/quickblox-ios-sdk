//
//  SelectUserTableViewCell.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/26/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "SelectUserTableViewCell.h"
#import "CornerView.h"

@interface SelectUserTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *checkboxImageView;
@property (weak, nonatomic) IBOutlet CornerView *colorMarker;
@property (weak, nonatomic) IBOutlet UILabel *userDescriptionLabel;

@end

@implementation SelectUserTableViewCell

- (void)setColorMarkerText:(NSString *)text andColor:(UIColor *)color {
	
	self.colorMarker.bgColor = color;
	self.colorMarker.title = text;
}

- (void)setUserDescription:(NSString *)userDescription {
	
	if (![_userDescription isEqualToString:userDescription]) {
		_userDescription = userDescription;
		self.userDescriptionLabel.text = userDescription;
	}
}

@end
