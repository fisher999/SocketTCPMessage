//
//  SocketServer.m
//  SocketMessageServer
//
//  Created by Victor on 26.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

#include <sys/socket.h>
#include <netinet/in.h>
#import "SMTCPServer.h"
#include <CoreFoundation/CoreFoundation.h>
#include <Foundation/Foundation.h>
#import "SMTCPSocketStreams.h"
@import CocoaAsyncSocket;


@interface SMTCPServer () <SMTCPSocketStreamsDelegate, GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *socket;

@end

@implementation SMTCPServer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _socketStreams = [[NSMutableArray alloc] init];
        _socket = [[GCDAsyncSocket alloc] initWithSocketQueue:dispatch_get_main_queue()];
        [_socket setDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (bool)bindWithPort: (NSInteger) port {
    NSError *error = nil;
    [_socket acceptOnPort:port error:&error];
    if (error) {
        NSLog(@"Cant bind - Error: %@", error);
        return false;
    }
    NSLog(@"binded with port %li", port);
    return true;
}

- (bool)bindWithIntervalFromFirstPort:(NSInteger)firstPort toEndPort:(NSInteger)endPort {
    for (NSInteger port = firstPort; port <= endPort; port++) {
        if ([self bindWithPort:port]) {
            return true;
        }
    }
    NSLog(@"Can not bind with interval: (%li - %li)", firstPort, endPort);
    return false;
}

- (void)listen {
    
}

- (void)sendMessage:(NSString *)message toSocketStreams:(SMTCPSocketStreams *)socketStreams {
    [socketStreams writeMessage:message dispatchAfter:3.0];
}

- (void)close {

}

- (void)dealloc
{
    [self close];
}

#pragma mark: SMTCPSocketStreamsDelegate
- (void)SMTCPSocketStreams:(SMTCPSocketStreams *)socketStreams didReceivedMessage:(NSString *)message atIp:(NSString *)ip atPort:(NSInteger)port {
    NSLog(@"message: %@ from ip: %@ at port: %li", message, ip, port);
    if ([message isEqualToString:@"Do you understand me?"]) {
        [self sendMessage:@"Yes, I do!" toSocketStreams:socketStreams];
    }
}

#pragma mark: GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    SMTCPSocketStreams *socketStream = [[SMTCPSocketStreams alloc] initWithGCDSocket:newSocket];
    [self.socketStreams addObject:socketStream];
    socketStream.delegate = self;
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"did connect");
}

@end
