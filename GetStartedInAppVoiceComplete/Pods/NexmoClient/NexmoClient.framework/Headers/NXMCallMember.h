//
//  NXMCallMember.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NXMCallMemberStatus) {
    NXMCallMemberStatusDialling,
    NXMCallMemberStatusCalling,
    NXMCallMemberStatusStarted,
    NXMCallMemberStatusAnswered,
    NXMCallMemberStatusCancelled,
    NXMCallMemberStatusCompleted
};

@interface NXMCallMember : NSObject

@property (nonatomic, readonly) NSString *callId;
@property (nonatomic, readonly) NSString *memberId;
@property (nonatomic, readonly) NSString *userId;
@property (nonatomic, readonly) NSString *userName;
@property (nonatomic, readonly) BOOL isMuted;
@property (nonatomic, readonly) NXMCallMemberStatus status;
@property (nonatomic, readonly) NSString *metaInfo;

- (void)hangup;
- (void)hold:(BOOL)isHold;
- (void)mute:(BOOL)isMute;
- (void)earmuff:(BOOL)isEarmuff;

@end


