//
//  MainViewController.m
//  GetStartedInAppVoice
//
//  Copyright © 2019 Nexmo. All rights reserved.
//

#import "MainViewController.h"
#import <NexmoClient/NexmoClient.h>

@interface MainViewController () <NXMClientDelegate, NXMCallDelegate>
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
    self.nexmoClient = [[NXMClient alloc] initWithToken:self.selectedUser.token];
    [self.nexmoClient setDelegate:self];
    [self.nexmoClient login];
}

#pragma mark NXMClientDelegate
- (void)connectionStatusChanged:(NXMConnectionStatus)status reason:(NXMConnectionStatusReason)reason {
    [self setWithConnectionStatus:status];
    // handle change in status
    NSLog(@"👁👁👁 connectionStatusChanged - status: %ld", (long)status);
    NSLog(@"👁👁👁 connectionStatusChanged - reason: %ld", (long)reason);
}

- (void)incomingCall:(nonnull NXMCall *)call {
    // handle an incoming call
    NSLog(@"📲 📲 📲 Incoming Call: %@", call);
    
    self.ongoingCall = call;
    [self displayIncomingCallAlert];
    
    [call.myCallMember mute:YES];
}


- (void)addedToConversation:(NXMConversation *)conversation {
    // handle joining a conversation
    NSLog(@"💬💬💬 Added to %@", conversation.displayName);
}

#pragma mark Buttons
- (IBAction)didCallOtherButtonPress:(UIButton *)sender {
    self.isInCall = YES;
    [self.nexmoClient call:@[self.otherUser.userId] callType:NXMCallTypeInApp delegate:self completion:^(NSError * _Nullable error, NXMCall * _Nullable call) {
        if(error) {
            NSLog(@"❌❌❌ call not created: %@", error);
            self.isInCall = NO;
            self.ongoingCall = nil;
            [self updateCallStatusLabelWithText:@""];
            return;
        }
        NSLog(@"🤙🤙🤙 call: %@", call);
        self.ongoingCall = call;
        [self setActiveViews];
    }];
}

- (IBAction)didEndButtonPress:(UIButton *)sender {
    [self.ongoingCall.myCallMember hangup];
}

#pragma mark NXMCallDelegate
- (void)statusChanged:(NXMCallMember *)callMember {
    NSLog(@"🤙🤙🤙 Call Status changed | participant: %@", callMember.user.name);
    if([callMember.user.userId isEqualToString:self.selectedUser.userId]) {
        [self statusChangedForMyMember:callMember];
    } else {
        [self statusChangedForOtherMember:callMember];
    }
}

- (void)statusChangedForMyMember:(NXMCallMember *)myMember {
    [self updateCallStatusLabelWithStatus:myMember.status];
    
    //Handle Hangup
    if(myMember.status == NXMCallMemberStatusCancelled || myMember.status == NXMCallMemberStatusCompleted) {
        self.ongoingCall = nil;
        self.isInCall = NO;
        [self updateCallStatusLabelWithText:@""];
        [self setActiveViews];
    }
}

- (void)statusChangedForOtherMember:(NXMCallMember *)otherMember {
    if(otherMember.status == NXMCallMemberStatusCancelled || otherMember.status == NXMCallMemberStatusCompleted) {
        [self.ongoingCall.myCallMember hangup];
    }
}

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
    
    UIAlertAction* declineAction = [UIAlertAction actionWithTitle:@"Decline" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf didPressDeclineIncomingCall];
    }];
    
    [alertController addAction:answerAction];
    [alertController addAction:declineAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didPressAnswerIncomingCall {
    __weak MainViewController *weakSelf = self;
    [weakSelf.ongoingCall answer:self completionHandler:^(NSError * _Nullable error) {
        if(error) {
            NSLog(@"❌❌❌ error answering call: %@", error.localizedDescription);
            [weakSelf displayAlertWithTitle:@"Answer Call" andMessage:@"Error answering call"];
            weakSelf.ongoingCall = nil;
            weakSelf.isInCall = NO;
            [self updateCallStatusLabelWithText:@""];
            [weakSelf setActiveViews];
            return;
        }
        NSLog(@"🤙🤙🤙 call answered");
        self.isInCall = YES;
        [weakSelf setActiveViews];
    }];
}

- (void)didPressDeclineIncomingCall {
    __weak MainViewController *weakSelf = self;
    [weakSelf.ongoingCall reject:^(NSError * _Nullable error) {
        if(error) {
            NSLog(@"❌❌❌ error declining call: %@", error.localizedDescription);
            [weakSelf displayAlertWithTitle:@"Decline Call" andMessage:@"Error declining call"];
            return;
        }
        NSLog(@"🤙🤙🤙 call declined");
        weakSelf.ongoingCall = nil;
        weakSelf.isInCall = NO;
        [self updateCallStatusLabelWithText:@""];
        [weakSelf setActiveViews];
    }];
}


@end
