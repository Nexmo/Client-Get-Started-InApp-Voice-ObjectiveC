//
//  IAVUserDetails.m
//  GetStartedInAppVoice
//
//  Copyright © 2019 Nexmo. All rights reserved.
//

#import "IAVUserDetails.h"
#import "IAVAppDefine.h"

@implementation IAVUserDetails

-(instancetype)initWithName:(NSString *)name userId:(NSString *)userId token:(NSString *)token {
    if(self = [super init]) {
        self.name = name;
        self.userId = userId;
        self.token = token;
    }
    return self;
}

+(instancetype)Jane {
    return [[IAVUserDetails alloc] initWithName:kInAppVoiceJaneName userId:kInAppVoiceJaneUserId token:kInAppVoiceJaneToken];
}

+(instancetype)Joe {
    return [[IAVUserDetails alloc] initWithName:kInAppVoiceJoeName userId:kInAppVoiceJoeUserId token:kInAppVoiceJoeToken];
}
@end
