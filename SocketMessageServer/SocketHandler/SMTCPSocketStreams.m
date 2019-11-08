//
//  SocketHandler.m
//  SocketMessageServer
//
//  Created by Victor on 27.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMTCPSocketStreams.h"
#import "SMTCPServer.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
@import CocoaAsyncSocket;

@interface SMTCPSocketStreams () <GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *socket;

@end

@implementation SMTCPSocketStreams
- (instancetype)initWithIp:(NSString *)ip andPort:(NSInteger)port withSocketQueue:(dispatch_queue_t)socketQueue delegateQueue:(dispatch_queue_t)delegateQueue {
    if (self = [super init]) {
        _ip = ip;
        _port = port;
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:delegateQueue socketQueue:socketQueue];
    }
    return self;
}

- (instancetype)initWithGCDSocket:(GCDAsyncSocket *)socket {
    if (self = [super init]) {
        _socket = socket;
        _ip = [_socket connectedHost];
        _ip = [_socket connectedHost];
        [_socket setDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return self;
}

- (bool)connect {
    [_socket readDataWithTimeout:-1 tag:0];
    NSError *error = nil;
    _isConnected = [_socket connectToHost:_ip onPort:_port error:&error];
    if (error) {
        NSLog(@"Error on connect: %@", error);
    }
    return _isConnected;
}

-(void)setConnected: (bool) connected {
    _isConnected = connected;
}

- (void)writeMessage:(NSString *)message dispatchAfter:(NSTimeInterval)time {
    NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    [_socket writeData:messageData withTimeout:-1 tag:0];
}

- (NSString *)readData: (NSData *)data {
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}


- (void)close {
    [_socket disconnect];
}

- (void)dealloc {
    [self close];
}
@end


@implementation SMTCPSocketStreams (GCDAsyncSocketDelegate)
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    [sock readDataWithTimeout:-1 tag:0];
    NSString *message = [self readData:data];
    [_delegate SMTCPSocketStreams:self didReceivedMessage:message atIp:_ip atPort:_port];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    [_delegate SMTCPSocketStreamsDidConnect:self];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
    [_delegate SMTCPSocketStreamsDidDiconnect:self];
}

@end
