//
//  NewMeetingViewController.h
//  MeetingiOS
//
//  Created by Lucas Costa  on 02/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewMeetingViewController : UIViewController

//MARK:- Properties
@property (nonatomic, weak) IBOutlet UIView* firstView;
@property (nonatomic, weak) IBOutlet UIView* secondView;
@property (nonatomic, weak) IBOutlet UIView* thirdView;
@property (nonatomic, weak) IBOutlet UIView* fourthView;
@property (nonatomic, weak) IBOutlet UIView* fifthView;
@property (nonatomic, weak) IBOutlet UILabel* dateTime;

@end

NS_ASSUME_NONNULL_END
