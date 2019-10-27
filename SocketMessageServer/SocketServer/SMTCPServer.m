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

@interface SMTCPServer ()
@property (strong, nonatomic) SMTCPSocketStreams *socketStreams;
@end

@implementation SMTCPServer {
    CFSocketRef cfSocket;
}
- (void)bindWithPort: (NSInteger) port {
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
     
    CFSocketSetAddress(cfSocket, sincfd);
    CFRelease(sincfd);
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
}

static void handleConnect(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    NSLog(@"RECIEVED CONNECTION REQUEST \n");
    if (kCFSocketAcceptCallBack == type) {
        CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;
        SMTCPSocketStreams *socketStreams = [[SMTCPSocketStreams alloc] init];
        CFSocketContext *context = (CFSocketContext *)info;
        SMTCPServer *pointerToSelf = (__bridge SMTCPServer *)context->info;
        [socketStreams.delegate addDelegate:pointerToSelf];
        [socketStreams handleSocketEventsWithNativeHandle:nativeSocketHandle];
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

@end
