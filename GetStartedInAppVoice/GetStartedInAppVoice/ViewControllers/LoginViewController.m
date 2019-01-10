//
//  ViewController.m
//  GetStartedInAppVoice
//
//  Copyright © 2019 Nexmo. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import "IAVUserDetails.h"

@interface LoginViewController ()
@property IAVUserDetails *selectedUser;
@property IAVUserDetails *otherUser;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)didPressLoginJaneButton:(UIButton *)sender {
    self.selectedUser = [IAVUserDetails Jane];
    self.otherUser = [IAVUserDetails Joe];
}


- (IBAction)didPressLoginJoeButton:(UIButton *)sender {
    self.selectedUser = [IAVUserDetails Joe];
    self.otherUser = [IAVUserDetails Jane];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.destinationViewController isKindOfClass:MainViewController.class]) {
        [((MainViewController *) segue.destinationViewController) updateWithSelectedUser:self.selectedUser andOtherUser:self.otherUser];
    }
}

@end
