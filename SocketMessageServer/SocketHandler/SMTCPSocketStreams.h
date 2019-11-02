//
//  SocketHandler.h
//  SocketMessageClient
//
//  Created by Victor on 27.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMTCPMulticastDelegate.h"

@class SMTCPSocketStreams;

@protocol SMTCPSocketStreamsDelegate
- (void)SMTCPSocketStreams: (SMTCPSocketStreams *) socketStreams didReceivedMessage: (NSString *) message;
@end

@interface SMTCPSocketStreams : NSObject

@property (strong, nonatomic) SMTCPMulticastDelegate<SMTCPSocketStreamsDelegate> *delegate;
@property (assign, readonly, nonatomic) bool isConnected;

- (void)connectWithIp:(NSString *) ip andPort: (UInt32) port;
- (void)handleSocketEventsWithNativeHandle:(CFSocketNativeHandle) handle;
- (void)writeMessage: (NSString *) message;
- (void)close;

@end
