//
//  DetailsTableViewController.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 14/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

#import "DetailsTableViewController.h"
#import "ContactCollectionView.h"
#import "UIView+CornerShadows.h"
#import <MeetingiOS-Swift.h>

@class User;

@interface DetailsTableViewController ()

@property (nonatomic) NSMutableArray<User*> *employees_user;
@property (nonatomic) NSMutableArray<Contact*> *employees_contact;
@property (nonatomic) ContactCollectionView* contactCollectionView;
@property (nonatomic) User* manager;
@property (nonatomic) BOOL isManager;
@property (nonatomic) BOOL chooseNumberOfTopics;
@property (nonatomic) BOOL chooseStartTime;
@property (nonatomic) BOOL chooseEndTime;

//MARK:- Loading View
@property (nonatomic) UIVisualEffectView *blurEffectView;
@property (nonatomic) UIActivityIndicatorView* loadingIndicator;

@end

@implementation DetailsTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view setBackgroundColor:[[UIColor alloc] initWithHexString:@"#FAFAFA" alpha:1]];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = NSLocalizedString(@"dateFormat", "");
    
    self.meetingName.text = self.meeting.theme;
    self.numbersOfPeople.text = self.meeting.employees.count > 0 ? [NSString stringWithFormat:@"%ld", self.meeting.employees.count] : NSLocalizedString(@"None", "") ;
    self.topicsPerPerson.text = [NSString stringWithFormat:@"%lli", self.meeting.limitTopic];
    self.startsDate.text = [formatter stringFromDate:self.meeting.initialDate]; 
    self.endesDate.text = [formatter stringFromDate:self.meeting.finalDate];
  
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
   // [self setupNavigationController];
    [self setupViews];
    [self showLoadingView];
    self.employees_user = [[NSMutableArray alloc] init];
    self.employees_contact = [[NSMutableArray alloc] init];

    [self loadingMeetingsParticipants:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.meetingAdmin.text = self.manager.name;
            
            self.contactCollectionView = [[ContactCollectionView alloc] init];
            [self.contactCollectionView addContacts:[self.employees_contact copy]];
            
            NSString* owner_email = [NSUserDefaults.standardUserDefaults valueForKey:@"email"];
                    
            if(owner_email) {
                self.isManager = [self.manager.email isEqualToString:owner_email];
            } else {
                self.isManager = false;
            }
            
            if(!self.isManager) {
                [self.modifyName setHidden:YES];
                [self.tableView setAllowsSelection:NO];
            }
            
            [self removeLoadingView];
        });
    }];
    
}

/// Carregando os contatos da reunião.
- (void) loadingMeetingsParticipants: (void (^) (void)) completionHandler {
    
    NSMutableArray<CKRecordID*>* participants = [[NSMutableArray alloc]init];
    
    for (CKReference* employee in self.meeting.employees) {
        [participants addObject:employee.recordID];
    }
        
    [participants addObject:_meeting.manager.recordID];
    
    [CloudManager.shared fetchRecordsWithRecordIDs:[participants copy] desiredKeys:Nil finalCompletion:^(NSDictionary<CKRecordID *,CKRecord *> * _Nullable records, NSError * _Nullable error) {
        
        if (error == Nil) {
            
            for(CKRecord* record in records.allValues) {
                
                if ([record.recordID isEqual:self.meeting.manager.recordID]) {
                    self.manager = [[User alloc] initWithRecord:record];
                } else {
                    User* user = [[User alloc] initWithRecord:record];
                    Contact* contact = [[Contact alloc]initWithUser:user];
                    [self.employees_user addObject:user];
                    [self.employees_contact addObject:contact];
                }
            }
            
        } else {
            NSLog(@"%@", error.userInfo);
            return;
        }
        
        completionHandler();
    }];
    
}

/// Adicionando características as views.
- (void) setupViews {
    
    for(UIView* view in _views) {
        
        [view setBackgroundColor:[[UIColor alloc]initWithHexString:@"#FEFEFF" alpha:1]];
        
        switch (view.tag) {
            case 2:
                [self.view setupCornerRadiusShadow:kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner];
                break;
            case 3:
                [self.view setupCornerRadiusShadow: kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner];
                break;
            default:
                [self.view setupCornerRadiusShadow];
        }
    }
}

/// Apresentar view de loading.
- (void) showLoadingView {
    
     UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial]; 
    _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    
    [_loadingIndicator setHidesWhenStopped:YES];
    [_loadingIndicator startAnimating];
    
    [_blurEffectView setFrame:self.view.bounds];
    [_blurEffectView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];  
    [_blurEffectView.contentView addSubview:_loadingIndicator];
    
    [[_loadingIndicator.centerXAnchor constraintEqualToAnchor:_blurEffectView.centerXAnchor] setActive:YES];
    [[_loadingIndicator.centerYAnchor constraintEqualToAnchor:_blurEffectView.centerYAnchor] setActive:YES];
    [_loadingIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addSubview:_blurEffectView];
    
}


/// Remover view de loading.
- (void) removeLoadingView {
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.loadingIndicator setAlpha:0];
        [self.blurEffectView setAlpha:0];
    } completion:^(BOOL finished) {
        [self.blurEffectView removeFromSuperview];
    }];
    
    
}

/// Adicionando as configurações da navigation controller.
- (void) setupNavigationController {
    [self.navigationController setTitle:@"Details"];
    [self.navigationController.navigationBar setPrefersLargeTitles:NO];
    [self.navigationController.navigationItem setHidesBackButton:YES];
    self.navigationController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action: @selector(popViewControllerAnimated:)];
}

//MARK:- TableView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return 15;
    }
    
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* view = [[UIView alloc] init];
    [view setBackgroundColor:UIColor.clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
      
    switch (indexPath.section) {
          case 2:
              switch (indexPath.row) {
                  case 1:
                      if(!_chooseStartTime) {
                          
                          [UIView animateWithDuration:0.5 animations:^{
                              [self.startDatePicker setHidden:YES];
                          }];
                          
                          return 0;
                      } else {
                          [self.startDatePicker setHidden:NO];
                      }
                      break;
                  case 3:
                      if(!_chooseEndTime) {
                          
                          UIView* view = [_views objectAtIndex:3];
                          [view.layer setCornerRadius:5];
                          view.layer.maskedCorners = kCALayerMaxXMaxYCorner | kCALayerMinXMaxYCorner;
                          
                          [UIView animateWithDuration:0.5 animations:^{
                              [self.finishDatePicker setHidden:YES];
                          }];
                          
                          return 0;
                      } else {                        
                          UIView* view = [_views objectAtIndex:3];
                          [view.layer setCornerRadius:0];
                          [self.finishDatePicker setHidden:NO];
                      }
                  default:
                      break;
              }
              break;
          case 3:
              if(indexPath.row == 1 && _contactCollectionView.contacts.count == 0) {
                  UIView* view = [self.views objectAtIndex:3];
                  view.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMinYCorner | kCALayerMaxXMaxYCorner | kCALayerMinXMaxYCorner;
                  return 0;
                  
              } else if (_contactCollectionView.contacts.count != 0) {
                  UIView* view = [self.views objectAtIndex:3];
                  view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
              }
              break;
          case 4:
              switch (indexPath.row) {
                  case 0:
                      if(_chooseNumberOfTopics) {
                          UIView* view = [self.views objectAtIndex:5];
                          view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                      } else {
                          UIView* view = [self.views objectAtIndex:5];
                          view.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMinYCorner | kCALayerMaxXMaxYCorner | kCALayerMinXMaxYCorner;
                      }
                      break;
                  case 1:
                      if(!_chooseNumberOfTopics) {
                          return 0;
                      }
                      break;
                  default:
                      break;
              }
          default:
              break;
      }
      
      return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 2:
            switch (indexPath.row) {
                case 0:
                    _chooseStartTime = !_chooseStartTime;
                    break;
                case 2:
                    _chooseEndTime = !_chooseEndTime;
                default:
                    break;
            }
            
            break;
        case 3:
            if(indexPath.row == 0) {
                [self performSegueWithIdentifier:@"SelectContacts" sender:nil];
            }
            break;
        case 4:
            if(indexPath.row == 0) {
                _chooseNumberOfTopics = !_chooseNumberOfTopics;      
            }
            break;
        default:
            break;
    }
    
    [tableView beginUpdates];
    [tableView endUpdates];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    
    if (section == 1) {
        return @"Created By";
    }
    
    return Nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"SelectContacts"]) {
        
        ContactViewController* contactViewController = [segue destinationViewController];
        
        if(contactViewController) {
            [contactViewController setContactCollectionView:_contactCollectionView];
        }
    }
}


@end

