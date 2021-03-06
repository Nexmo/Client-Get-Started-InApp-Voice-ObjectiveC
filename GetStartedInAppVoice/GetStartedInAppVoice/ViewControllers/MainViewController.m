//
//  MainViewController.m
//  GetStartedInAppVoice
//
//  Copyright © 2019 Nexmo. All rights reserved.
//

#import "MainViewController.h"
#import <NexmoClient/NexmoClient.h>

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIView *makeCallView;
@property (weak, nonatomic) IBOutlet UIView *inCallView;
@property (weak, nonatomic) IBOutlet UIButton *callOtherButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectionStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *callStatusLabel;

@property IAVUserDetails *selectedUser;
@property IAVUserDetails *otherUser;
@property BOOL isInCall;


@property NXMClient *nexmoClient;
@property NXMCall *ongoingCall;
@end

@implementation MainViewController

#pragma mark - setup

- (void)updateWithSelectedUser:(IAVUserDetails *)selectedUser andOtherUser:(IAVUserDetails *)otherUser {
    self.selectedUser = selectedUser;
    self.otherUser = otherUser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self setWithConnectionStatus:NXMConnectionStatusDisconnected];
    [self setupNexmoClient];
}

- (void)setupViews {
    self.nameLabel.text = [@"Hello " stringByAppendingString:self.selectedUser.name];
    [self.callOtherButton setTitle:[@"Call " stringByAppendingString:self.otherUser.name] forState:UIControlStateNormal];
    self.isInCall = NO;
    [self updateCallStatusLabelWithText:@""];
    [self setActiveViews];
}

- (void)setActiveViews {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setActiveViews];
        });
        return;
    }
    
    if(self.isInCall) {
        self.makeCallView.hidden = YES;
        self.inCallView.hidden = NO;
    } else {
        self.makeCallView.hidden = NO;
        self.inCallView.hidden = YES;
    }
}

- (void)setWithConnectionStatus:(NXMConnectionStatus)conenctionStatus {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setWithConnectionStatus:conenctionStatus];
        });
        return;
    }

    
    switch (conenctionStatus) {
        case NXMConnectionStatusDisconnected:
            self.callOtherButton.enabled = NO;
            self.connectionStatusLabel.text = @"Connection Status: not connected";
            break;
            case NXMConnectionStatusConnecting:
            self.callOtherButton.enabled = NO;
            self.connectionStatusLabel.text = @"Connection Status: connecting";
            break;
            case NXMConnectionStatusConnected:
            self.callOtherButton.enabled = YES;
            self.connectionStatusLabel.text = @"Connection Status: connected";
            break;
        default:
            break;
    }
}

#pragma mark - User Input

- (IBAction)didLogoutButtonPress:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Alerts
- (void)displayAlertWithTitle:(nonnull NSString *)title andMessage:(nonnull NSString *)message {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self displayAlertWithTitle:title andMessage:message];
        });
        return;
    }
    
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    [alertController addAction:defaultAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - Tutorial Methods
#pragma mark Setup
- (void)setupNexmoClient {

}

#pragma mark NXMClientDelegate



#pragma mark Buttons
- (IBAction)didCallOtherButtonPress:(UIButton *)sender {

}

- (IBAction)didEndButtonPress:(UIButton *)sender {

}

#pragma mark NXMCallDelegate


- (void)updateCallStatusLabelWithText:(NSString *)text {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateCallStatusLabelWithText:text];
        });
        return;
    }
    self.callStatusLabel.text = text;
}

- (void)updateCallStatusLabelWithStatus:(NXMCallMemberStatus)status {
    
    NSString *callStatusText = @"";
    switch (status) {
        case NXMCallMemberStatusCancelled:
            callStatusText = @"Call Cancelled";
            break;
        case NXMCallMemberStatusCompleted:
            callStatusText = @"Call Completed";
            break;
        case NXMCallMemberStatusDialling:
            callStatusText = @"Dialing";
            break;
        case NXMCallMemberStatusCalling:
            callStatusText = @"Calling";
            break;
        case NXMCallMemberStatusStarted:
            callStatusText = @"Call Started";
            break;
        case NXMCallMemberStatusAnswered:
            callStatusText = @"Answered";
            break;
        default:
            break;
    }
    
    [self updateCallStatusLabelWithText:callStatusText];
}


#pragma mark IncomingCall

- (void)displayIncomingCallAlert {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self displayIncomingCallAlert];
        });
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Incoming Call"
                                                                   message:self.otherUser.name
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    __weak MainViewController *weakSelf = self;
    UIAlertAction* answerAction = [UIAlertAction actionWithTitle:@"Answer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf didPressAnswerIncomingCall];
    }];
    
    UIAlertAction* rejectAction = [UIAlertAction actionWithTitle:@"Reject" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf didPressRejectIncomingCall];
    }];
    
    [alertController addAction:answerAction];
    [alertController addAction:rejectAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didPressAnswerIncomingCall {

}

- (void)didPressRejectIncomingCall {

}


@end
