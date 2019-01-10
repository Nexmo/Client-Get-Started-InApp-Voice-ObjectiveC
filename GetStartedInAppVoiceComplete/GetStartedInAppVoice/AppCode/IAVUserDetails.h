//
//  IAVUserDetails.h
//  GetStartedInAppVoice
//
//  Copyright © 2019 Nexmo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IAVUserDetails : NSObject
@property NSString *name;
@property NSString *userId;
@property NSString *token;

-(instancetype)initWithName:(NSString *)name userId:(NSString *)userId token:(NSString *)token;

+(instancetype)Jane;
+(instancetype)Joe;
@end

