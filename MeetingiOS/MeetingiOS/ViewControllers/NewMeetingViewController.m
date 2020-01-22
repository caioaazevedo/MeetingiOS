//
//  NewMeetingViewController.m
//  MeetingiOS
//
//  Created by Lucas Costa  on 02/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import "NewMeetingViewController.h"
#import <MeetingiOS-Swift.h>
#import "NewMeetingViewController+NameMeetingValidation.h"
#import "Contact.h"
#import "ContactCollectionView.h"
#import "UIView+CornerShadows.h"
#import "TopicsPerPersonPickerView.h"

@interface NewMeetingViewController () <TopicsPerPersonPickerViewDelegate, DatePickersSetup>

//MARK:- Properties
@property (nonatomic, nullable) ContactCollectionView* contactCollectionView;
@property (nonatomic, nonnull) Meeting* meeting;
@property (nonatomic, nonnull) NSArray<CKRecord*>* participants;
@property (nonatomic, nonnull) UIAlertController* alertLoading;
@property (nonatomic) BOOL chooseNumberOfTopics;
@property (nonatomic) BOOL chooseStartTime;
@property (nonatomic) BOOL chooseEndTime;
@property (nonatomic) TopicsPerPersonPickerView* topicsPickerView; 
@property (nonatomic, nonnull) NSDateFormatter* formatter;


//MARK:- Methods
///Criando a reunião no Cloud Kit.
- (void) createMeetingInCloud;

@end

@implementation NewMeetingViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(_contactCollectionView)
        _contactCollectionView.isRemoveContact = NO;
    
    [self.navigationController.navigationBar setPrefersLargeTitles:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Construtores
    //Cor do Background
    [self.view setBackgroundColor:[[UIColor alloc] initWithHexString:@"#FAFAFA" alpha:1]];
    
    //Iniciando nova reunião.
    CKRecord* record = [[CKRecord alloc] initWithRecordType:@"Meeting"];
    
    _formatter = [[NSDateFormatter alloc] init];
    [_formatter setDateFormat:NSLocalizedString(@"dateFormat", "")];
    _startsDateTime.text = _endesDateTime.text = [_formatter stringFromDate:NSDate.now];
    [self setupPickersWithStartDatePicker:_startDatePicker finishDatePicker:_finishDatePicker];
            
     _meeting = [[Meeting alloc] initWithRecord:record];
     _participants = [[NSMutableArray alloc] init];
    _topicsPickerView = [[TopicsPerPersonPickerView alloc] init];
    _colorMetting.backgroundColor = [[UIColor alloc] initWithHexString:@"#93CCB2" alpha:1];
    
    self.numbersOfPeople.text = NSLocalizedString(@"None", "");
    
    _nameMetting.delegate = self;
    _pickerView.delegate = _topicsPickerView;
    [_topicsPickerView setDelegate:self];
    
    _chooseNumberOfTopics = NO;
    _chooseStartTime = NO;
    _chooseEndTime = NO;
    
    [self setupCollectionViewContacts];
    [self setupViews];
    
    NSString* title = NSLocalizedString(@"New meeting", "");
    
    [self.navigationItem setTitle:title];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(createMeetingInCloud)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if([_contactCollectionView.contacts count] != 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                [self.tableView beginUpdates];
                [self.tableView endUpdates];
                self.numbersOfPeople.text = [NSString stringWithFormat:@"%ld", self.contactCollectionView.contacts.count];                   
                [self.collectionView reloadData];
            }];
        });
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
            self.numbersOfPeople.text = NSLocalizedString(@"None", "");
            [self.view layoutIfNeeded];
        }];
    }
}

//MARK:- UIViews
- (void) setupViews {
    
    for (UIView* view in self.views) {
        
        [view setBackgroundColor:[[UIColor alloc]initWithHexString:@"#FEFEFF" alpha:1]];
        
        switch (view.tag) {
            case 1:
                [view setupCornerRadiusShadow:kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner]; 
                break;
            case 2:
                [view setupCornerRadiusShadow:kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner];
                break;
            default:
                [view setupCornerRadiusShadow];
        }
    }
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 1:
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
        case 2:
            if(indexPath.row == 0) {
                [self performSegueWithIdentifier:@"SelectContacts" sender:nil];
            }
            break;
        case 3:
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 1:
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
                        
                        UIView* view = [_views objectAtIndex:2];
                        [view.layer setCornerRadius:5];
                        view.layer.maskedCorners = kCALayerMaxXMaxYCorner | kCALayerMinXMaxYCorner;
                        
                        [UIView animateWithDuration:0.5 animations:^{
                            [self.finishDatePicker setHidden:YES];
                        }];
                        
                        return 0;
                    } else {                        
                        UIView* view = [_views objectAtIndex:2];
                        [view.layer setCornerRadius:0];
                        [self.finishDatePicker setHidden:NO];
                    }
                default:
                    break;
            }
            break;
        case 2:
            if(indexPath.row == 1 && _contactCollectionView.contacts.count == 0) {
                UIView* view = [self.views objectAtIndex:3];
                view.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMinYCorner | kCALayerMaxXMaxYCorner | kCALayerMinXMaxYCorner;
                return 0;
                
            } else if (_contactCollectionView.contacts.count != 0) {
                UIView* view = [self.views objectAtIndex:3];
                view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
            }
            break;
        case 3:
            switch (indexPath.row) {
                case 0:
                    if(_chooseNumberOfTopics) {
                        UIView* view = [self.views objectAtIndex:4];
                        view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                    } else {
                        UIView* view = [self.views objectAtIndex:4];
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


/// Atribuindo o delegate da view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"SelectContacts"]) {
        
        ContactViewController* contactViewController = [segue destinationViewController];
         
        if(contactViewController) {
            [contactViewController setContactCollectionView:_contactCollectionView];
        }
        
    } else if ([segue.identifier isEqualToString:@"SelectColor"]) {
        
        SelectColorViewController* nextViewController = [segue destinationViewController];
        
        if(nextViewController) {
            [nextViewController setDelegate:self];
            [nextViewController setSelectedColor: self.colorMetting.backgroundColor.toHexString];
        }
    }
}

-(void) createMeetingInCloud {
    
    NSString* theme =  [_nameMetting.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        
    if(theme.length == 0) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Meeting", "") message:NSLocalizedString(@"Choose a name for create a meeting.", "") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        
        [alert addAction:action];                    
        
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self showLoadingIndicator];

    CKRecordID* recordID = [[CKRecordID alloc] initWithRecordName:[NSUserDefaults.standardUserDefaults valueForKey:@"recordName"]];
    CKReference* manager = [[CKReference alloc] initWithRecordID:recordID action:CKReferenceActionNone];
    
    [_meeting setManager:manager];
    [_meeting setTheme:theme];
    [_meeting setColor: _colorMetting.backgroundColor.toHexString];
    [_meeting setInitialDate:[_formatter dateFromString:_startsDateTime.text]];
    [_meeting setFinalDate:[_formatter dateFromString:_endesDateTime.text]];
    [_meeting setLimitTopic:_numbersOfTopics.text.integerValue];
    
    for(CKRecord* record in _participants) {
        
        User* user = [[User alloc] initWithRecord:record];
        [user registerMeetingWithMeeting:[[CKReference alloc] initWithRecord:_meeting.record action:CKReferenceActionNone]];
        [_meeting addingNewEmployee:[[CKReference alloc]initWithRecord:record action:CKReferenceActionNone]];
    }
    
    [CloudManager.shared createRecordsWithRecords:@[_meeting.record] perRecordCompletion:^(CKRecord * _Nonnull record, NSError * _Nullable error) {
        if(error) {
            NSLog(@"Create -> %@", [error userInfo]);
        }
    } finalCompletion:^{
        NSLog(@"Create Record");
        
        [CloudManager.shared updateRecordsWithRecords:self.participants perRecordCompletion:^(CKRecord * _Nonnull record, NSError * _Nullable error) {
            if(error) {
                NSLog(@"Update -> %@", [error userInfo]);
            }
        } finalCompletion:^{
            NSLog(@"Update Users");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray<UIViewController *>* viewControllers = self.navigationController.viewControllers;
                NSUInteger vcCount = [self.navigationController.viewControllers count];
                MyMeetingsViewController* previousVC = (MyMeetingsViewController *)[viewControllers objectAtIndex:vcCount -2];
                previousVC.newMeeting = self->_meeting;
                
                [self.alertLoading dismissViewControllerAnimated:YES completion:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            });
        }];
    }];
}

- (void)chooseColorMeeting:(id)sender{
    [self performSegueWithIdentifier:@"SelectColor" sender:Nil];
}

- (void)selectedColor:(NSString *)hex {
    //Pegar cor de acordo com o hex    
    _colorMetting.backgroundColor = [[UIColor alloc] initWithHexString:hex alpha:1];
}

- (void)getRecordForSelectedUsers {
    
    NSMutableArray<NSString*>* allEmails = [[NSMutableArray alloc] init];
    NSMutableArray<CKRecord*>* participants_aux = [[NSMutableArray alloc] init];
    NSPredicate* predicate;
    
    for (Contact* contact in [_contactCollectionView contacts]) {
        [allEmails addObject:contact.email];
    }
    
    predicate = [NSPredicate predicateWithFormat:@"email IN %@", allEmails];
    
    [CloudManager.shared readRecordsWithRecorType:@"User" predicate:predicate desiredKeys:@[@"recordName"] perRecordCompletion:^(CKRecord * _Nonnull record) {
        
        [participants_aux addObject:record];
        
    } finalCompletion:^{
        self.participants = [participants_aux copy];
    }];
}


/// Criando uma view que indica um loading quando criada uma reunião.
- (void) showLoadingIndicator {

    _alertLoading = [UIAlertController alertControllerWithTitle:Nil message:NSLocalizedString(@"Creating Meeting...","") preferredStyle:UIAlertControllerStyleAlert];
    
    UIActivityIndicatorView* loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    
    [loadingIndicator setHidesWhenStopped:YES];
    [loadingIndicator startAnimating];
    
    [_alertLoading.view addSubview:loadingIndicator];
    
    [[loadingIndicator.centerYAnchor constraintEqualToAnchor:_alertLoading.view.centerYAnchor constant:0] setActive:YES];
    [[loadingIndicator.leftAnchor constraintEqualToAnchor:_alertLoading.view.leftAnchor constant:20] setActive:YES];
    [loadingIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self presentViewController:_alertLoading animated:YES completion:Nil];
}

//MARK:- CollectionViewContacts
/// Inicializando a collection view de contatos.
- (void) setupCollectionViewContacts {
    
    _contactCollectionView = [[ContactCollectionView alloc] initWithRemoveContact:NO];
    _collectionView.allowsSelection = NO;
    _collectionView.delegate = _contactCollectionView;
    _collectionView.dataSource = _contactCollectionView;
    [_collectionView registerNib:[UINib nibWithNibName:@"ContactCollectionViewCell" bundle:Nil] forCellWithReuseIdentifier:@"ContactCollectionCell"];
    [_collectionView.layer setMaskedCorners:kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner];
    [_collectionView.layer setCornerRadius:7];
}

//MARK:- TopicsPerPersonPickerViewDelegate 
- (void)changedNumberOfTopics:(NSInteger)amount {
    [self.numbersOfTopics setText:[NSString stringWithFormat:@"%ld", amount]];
}

//MARK:- DatePickersSetup
- (void)modifieStartDateTimeWithDatePicker:(UIDatePicker *)datePicker {
    _startsDateTime.text = _endesDateTime.text = [self.formatter stringFromDate:datePicker.date];
    _finishDatePicker.minimumDate = _finishDatePicker.date = datePicker.date;
}

- (void)modifieEndTimeWithDatePicker:(UIDatePicker *)datePicker {
    _endesDateTime.text = [self.formatter stringFromDate:datePicker.date];
}

- (void)setupPickersWithStartDatePicker:(UIDatePicker *)startDatePicker finishDatePicker:(UIDatePicker *)finishDatePicker {
    
    startDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
    finishDatePicker.datePickerMode = UIDatePickerModeTime;
    startDatePicker.minimumDate = finishDatePicker.minimumDate = NSDate.now;

    [startDatePicker addTarget:self action:@selector(modifieStartDateTimeWithDatePicker:) forControlEvents:UIControlEventValueChanged];
    
    [finishDatePicker addTarget:self action:@selector(modifieEndTimeWithDatePicker:) forControlEvents:UIControlEventValueChanged];
}

@end
