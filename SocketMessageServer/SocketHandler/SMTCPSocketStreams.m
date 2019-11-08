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
- (instancetype)initWithIp:(NSString *)ip andPort:(NSInteger)port {
    if (self = [super init]) {
        _ip = ip;
        _port = port;
        _socket = [[GCDAsyncSocket alloc] initWithSocketQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (instancetype)initWithGCDSocket:(GCDAsyncSocket *)socket {
    if (self = [super init]) {
        _socket = socket;
        _ip = [_socket connectedHost];
        _ip = [_socket connectedHost];
    }
    return self;
}

- (bool)connect {
    [_socket setDelegate:self delegateQueue:dispatch_get_main_queue()];
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
    [_socket writeData:messageData withTimeout:time tag:0];
}

- (NSString *)readData: (NSData *)data {
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}


- (void)close {
    
}

- (void)dealloc {
    [self close];
}
@end


@implementation SMTCPSocketStreams (GCDAsyncSocketDelegate)
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *message = [self readData:data];
    [_delegate SMTCPSocketStreams:self didReceivedMessage:message atIp:_ip atPort:_port];
}
@end
