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
@property (assign, nonatomic) dispatch_queue_t queue;
@property (strong, nonatomic) NSMutableArray<GCDAsyncSocket *> *knownSockets;

@end

@implementation SMTCPServer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _socketStreams = [[NSMutableArray alloc] init];
        _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
        _socket = [[GCDAsyncSocket alloc] initWithSocketQueue:_queue];
    }
    return self;
}

- (bool)bindWithPort: (NSInteger) port {
    [_socket setDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_socket readDataWithTimeout:-1 tag:0];
    NSError *error = nil;
    bool isAccepted = [_socket acceptOnPort:port error:&error];
    if (error) {
        NSLog(@"Cant bind - Error: %@", error);
        return false;
    }
    if (isAccepted) {
        NSLog(@"binded with port %li", port);
    }
    return isAccepted;
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

- (void)sendMessage:(NSString *)message toSocket: (GCDAsyncSocket *)socket {
    NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), _queue, ^{
        [socket writeData:messageData withTimeout:-1 tag:0];
    });
}

- (NSString *)readData: (NSData *)data {
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (void)close {

}

- (void)dealloc
{
    [self close];
}

#pragma mark: GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    [sock readDataWithTimeout:-1 tag:0];
    sock.lo
    NSLog(@"port: %hu", sock.);
    NSString *message = [self readData:data];
    NSLog(@"message: %@ ", message);
    if ([message isEqualToString:@"Do you understand me?"]) {
        [self sendMessage:@"Yes, I do!" toSocket: sock];
        [_knownSockets addObject:sock];
        return;
    }
    if (![_knownSockets containsObject:sock]) {
        return;
    }
    unichar character = [[message lowercaseString] characterAtIndex:0];
    if (character >= 'k' && character <= 'z') {
        [self sendMessage:@"My name is Kapitan Volkov..." toSocket:sock];
    } else {
        [self sendMessage:@"I will kill you..." toSocket:sock];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"new socket port: %hu", newSocket.localPort);
    SMTCPSocketStreams *socketStream = [[SMTCPSocketStreams alloc] initWithGCDSocket:newSocket];
    newSocket.delegate = self;
    [newSocket readDataWithTimeout:-1 tag:0];
    [self.socketStreams addObject:socketStream];
    socketStream.delegate = self;
    NSLog(@"Accepted client %@:%hu", newSocket.localHost, newSocket.localPort);
}

@end
