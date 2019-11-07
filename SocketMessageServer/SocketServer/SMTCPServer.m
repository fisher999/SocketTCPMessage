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

@interface SMTCPServer () <SMTCPSocketStreamsDelegate>
@end

@implementation SMTCPServer {
    CFSocketRef cfSocket;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _socketStreams = [[NSMutableArray alloc] init];
    }
    return self;
}

- (bool)bindWithPort: (NSInteger) port {
    CFSocketContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    cfSocket = CFSocketCreate(
        kCFAllocatorDefault,
        PF_INET,
        SOCK_STREAM,
        IPPROTO_TCP,
        kCFSocketAcceptCallBack,
        handleConnect,
        &context);
    
    struct sockaddr_in sin;
    
    memset(&sin, 0, sizeof(sin));
    sin.sin_len = sizeof(sin);
    sin.sin_family = AF_INET;
    sin.sin_port = htons(port);
    sin.sin_addr.s_addr= INADDR_ANY;
     
    CFDataRef sincfd = CFDataCreate(
        kCFAllocatorDefault,
        (UInt8 *)&sin,
        sizeof(sin));
     
    CFSocketError error = CFSocketSetAddress(cfSocket, sincfd);
    CFRelease(sincfd);
    if (error) {
        [self close];
        return false;
    } else {
        NSLog(@"Binded with port: %li", port);
        return true;
    }
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
    if (cfSocket == nil) {
        return;
    }
    CFRunLoopSourceRef socketsource = CFSocketCreateRunLoopSource(
        kCFAllocatorDefault,
        cfSocket,
        0);
    CFRunLoopAddSource(
        CFRunLoopGetCurrent(),
        socketsource,
        kCFRunLoopDefaultMode);
    [[NSRunLoop currentRunLoop] run];
}

- (void)sendMessage:(NSString *)message toSocketStreams:(SMTCPSocketStreams *)socketStreams {
    [socketStreams writeMessage:message dispatchAfter:3.0];
}

static void handleConnect(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    if (kCFSocketAcceptCallBack == type) {
        CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;
        SMTCPSocketStreams *socketStream = [[SMTCPSocketStreams alloc] init];
        SMTCPServer *pointerToSelf = (__bridge SMTCPServer *)(info);
        [[pointerToSelf socketStreams] addObject:socketStream];
        socketStream.delegate = pointerToSelf;
        [socketStream handleSocketEventsWithNativeHandle:nativeSocketHandle];
    }
}

- (void)close {
    CFSocketInvalidate(cfSocket);
    CFRelease(cfSocket);
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

@end
