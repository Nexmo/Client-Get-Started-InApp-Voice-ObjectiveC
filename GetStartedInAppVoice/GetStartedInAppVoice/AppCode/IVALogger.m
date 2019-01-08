//
//  IVALogger.m
//  GetStartedInAppVoice
//
//  Created by Doron Biaz on 1/3/19.
//  Copyright © 2019 Nexmo. All rights reserved.
//

#import "IVALogger.h"

@implementation IVALogger

- (void)debug:(nullable NSString *)message {
    NSLog(@"IVALog (DEBUG): %@", message);
}

- (void)error:(nullable NSString *)message {
    NSLog(@"IVALog (ERROR): %@", message);
}

- (void)info:(nullable NSString *)message {
    NSLog(@"IVALog (INFO): %@", message);
}

- (void)warning:(nullable NSString *)message {
    NSLog(@"IVALog (WARNING): %@", message);
}

@end
