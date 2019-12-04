//
//  FinishedTopicsTableViewCell.h
//  MeetingiOS
//
//  Created by Paulo Ricardo on 12/4/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FinishedTopicsTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *topicDescriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *authorNameLabel;

@end

NS_ASSUME_NONNULL_END
