//
//  MainViewController.h
//  GetStartedInAppVoice
//
//  Copyright © 2019 Nexmo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAVUserDetails.h"

@interface MainViewController : UIViewController
- (void)updateWithSelectedUser:(IAVUserDetails *)selectedUser andOtherUser:(IAVUserDetails *)otherUser;
@end

