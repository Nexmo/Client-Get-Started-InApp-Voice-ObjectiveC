//
//  MainViewController.m
//  GetStartedInAppVoice
//
//  Copyright © 2019 Nexmo. All rights reserved.
//

#import "MainViewController.h"

#import <NexmoClient/NexmoClient.h>

@interface MainViewController () <NXMClientDelegate, NXMCallDelegate>
@property (weak, nonatomic) IBOutlet UIButton *callOtherButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectionStatusLabel;
@property (weak, nonatomic) IBOutlet UIView *makeCallView;
@property (weak, nonatomic) IBOutlet UIView *inCallView;

@property IAVUserDetails *selectedUser;
@property IAVUserDetails *otherUser;
@property BOOL isInCall;


@property NXMClient *nexmoClient;
@property NXMCall *ongoingCall;
@end

@implementation MainViewController

#pragma mark - setup
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self setWithIsConnected:NO];
    [self setupNexmoClient];
}

- (void)updateWithSelectedUser:(IAVUserDetails *)selectedUser andOtherUser:(IAVUserDetails *)otherUser {
    self.selectedUser = selectedUser;
    self.otherUser = otherUser;
}

- (void)setupView {
    self.nameLabel.text = [@"Hello " stringByAppendingString:self.selectedUser.name];
    
    [self.callOtherButton setTitle:[@"Call " stringByAppendingString:self.otherUser.name] forState:UIControlStateNormal];
    
    self.isInCall = NO;
    [self setActiveViews];
}

- (void)setActiveViews {
    if(self.isInCall) {
        self.makeCallView.hidden = YES;
        self.inCallView.hidden = NO;
    } else {
        self.makeCallView.hidden = NO;
        self.inCallView.hidden = YES;
    }
}

- (void)setWithIsConnected:(BOOL)isConnected {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setWithIsConnected:isConnected];
        });
        return;
    }
    
    if(isConnected) {
        self.callOtherButton.enabled = YES;
        self.connectionStatusLabel.text = @"Connection Status: connected";
    } else {
        self.callOtherButton.enabled = NO;
        self.connectionStatusLabel.text = @"Connection Status: not connected";
    }
}

-(void)setupNexmoClient {
    self.nexmoClient = [[NXMClient alloc] init];
    [self.nexmoClient setDelegate:self];
    [self.nexmoClient loginWithAuthToken:self.selectedUser.token];
}

#pragma mark - User Input

- (IBAction)didLogoutButtonPress:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didCallOtherButtonPress:(UIButton *)sender {
    self.isInCall = YES;
    [self.nexmoClient call:@[self.otherUser.userId] callType:NXMCallTypeInApp delegate:self completion:^(NSError * _Nullable error, NXMCall * _Nullable call) {
        if(error) {
            self.isInCall = NO;
            self.ongoingCall = nil;
            return;
        }
        self.ongoingCall = call;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setActiveViews];
        });
    }];
}

- (IBAction)didEndButtonPress:(UIButton *)sender {
    [self.ongoingCall hangup:^(NSError * _Nullable error) {
        if(error) {
            [self displayAlertWithTitle:@"Call Error" andMessage:@"Error while trying to hangup the call. Please try again"];
            return;
        }
        
        self.ongoingCall = nil;
        self.isInCall = NO;
        [self setActiveViews];
    }];
}

#pragma mark - NXMClientDelegate
- (void)connectionStatusChanged:(BOOL)isOnline {
    [self setWithIsConnected:isOnline];
}

- (void)loginStatusChanged:(nullable NXMUser *)user loginStatus:(BOOL)isLoggedIn withError:(nullable NSError *)error {
    if(error) {
        [self displayAlertWithTitle:@"Login Error" andMessage:@"Error performing login. Please make sure your credentials are valid and your device is connected to the internet"];
        
        return;
    }
}

- (void)tokenRefreshed {
    //User succesfully refreshed token.
}

#pragma mark - NXMCallDelegate
- (void)statusChanged:(NXMCallParticipant *)participant {
    
}

#pragma mark - Alerts

- (void)displayIncomingCallAlert {
    
}

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

@end
