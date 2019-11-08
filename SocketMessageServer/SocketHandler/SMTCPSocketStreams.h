//
//  SocketHandler.h
//  SocketMessageClient
//
//  Created by Victor on 27.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMTCPMulticastDelegate.h"

@class GCDAsyncSocket;
@class SMTCPSocketStreams;

@protocol SMTCPSocketStreamsDelegate
- (void)SMTCPSocketStreams: (SMTCPSocketStreams *) socketStreams didReceivedMessage: (NSString *) message atIp: (NSString *)ip atPort: (NSInteger) port;
@end

@interface SMTCPSocketStreams : NSObject

@property (weak, nonatomic) id<SMTCPSocketStreamsDelegate> delegate;
@property (assign, readonly, nonatomic) bool isConnected;
@property (assign, readonly, nonatomic) NSInteger port;
@property (strong, readonly, nonatomic) NSString *ip;

- (instancetype)initWithIp: (NSString *) ip andPort: (NSInteger) port;
- (instancetype)initWithGCDSocket: (GCDAsyncSocket *) socket;
- (bool)connect;
- (void)writeMessage: (NSString *) message dispatchAfter: (NSTimeInterval) time;
- (void)close;

@end
