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

@interface SMTCPSocketStreams () <NSStreamDelegate>
@end

@implementation SMTCPSocketStreams {
    __strong NSInputStream *_inputStream;
    __strong NSOutputStream *_outputStream;
    NSUInteger _currentOffset;
}

- (instancetype)initWithIp:(NSString *)ip andPort:(NSInteger)port {
    if (self = [super init]) {
        _ip = ip;
        _port = port;
    }
    return self;
}

- (void)connect {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)_ip, (UInt32)_port, &readStream, &writeStream);
    CFRetain(readStream);
    CFRetain(writeStream);
    _inputStream = (__bridge_transfer NSInputStream *)readStream;
    _outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    CFRelease(readStream);
    CFRelease(writeStream);
}

- (void)main {
    if (!(_inputStream && _outputStream)) {
        return;
    }
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream open];
    [_outputStream open];
    _inputStream.delegate = self;
    _isConnected = YES;
    CFRunLoopRun();
}

- (void)handleSocketEventsWithNativeHandle:(CFSocketNativeHandle) handle {
    [self setIpAndPortFromNativeSocketHandle:handle];
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, handle, &readStream, &writeStream);
    CFRetain(readStream);
    CFRetain(writeStream);
    CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    _inputStream = (__bridge_transfer NSInputStream *)readStream;
    _outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    CFRelease(readStream);
    CFRelease(writeStream);
}

- (void)setIpAndPortFromNativeSocketHandle: (CFSocketNativeHandle) nativeSocketHandle {
    uint8_t name[SOCK_MAXADDRLEN];
    socklen_t namelen = sizeof(name);
    NSData *peer = nil;
    if (0 == getpeername(nativeSocketHandle, (struct sockaddr *)name, &namelen)) {
        peer = [NSData dataWithBytes:name length:namelen];
    }
    struct sockaddr_in *socketaddress = (struct sockaddr_in*)name;

    // convert ip to string
    char *ipstr = malloc(INET_ADDRSTRLEN);
    struct in_addr *ipv4addr = &socketaddress->sin_addr;
    ipstr = inet_ntoa(*ipv4addr);
    
    // convert port to int
    int portNumber = socketaddress->sin_port;

    _ip   = [NSString stringWithFormat:@"%s", ipstr];
    _port = portNumber;
}

- (void)writeMessage:(NSString *)message {
    NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t *dataBytes = (uint8_t *)[messageData bytes];
    dataBytes += _currentOffset;
    NSUInteger length = [messageData length] - _currentOffset > 1024 ? 1024 : [messageData length] - _currentOffset;
    NSUInteger sentLength = [_outputStream write: dataBytes maxLength: length];
    if (sentLength > 0) {
        _currentOffset += sentLength;
        if (_currentOffset == [messageData length]) {
            _currentOffset = 0;
        }
    }
}

- (NSString *)readFromInputStream:(NSInputStream *) inputStream {
    uint8_t buffer[4096];
    NSInteger len;
    NSMutableString *total = [[NSMutableString alloc] init];
    while ([inputStream hasBytesAvailable]) {
        len = [inputStream read:buffer maxLength:sizeof(buffer)];
        if (len > 0) {
            [total appendString: [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding]];
        }
    }
    NSLog(@"message: %@", total);
    return total;
}


- (void)close {
    [_inputStream close];
    [_outputStream close];
    _isConnected = NO;
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)dealloc {
    [self close];
}

@end


@implementation SMTCPSocketStreams (NSStreamDelegate)

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable:
            if ([aStream isKindOfClass:[NSInputStream class]]) {
                NSString *message = [self readFromInputStream:(NSInputStream *) aStream];
                [_delegate SMTCPSocketStreams:self didReceivedMessage:message atIp:_ip atPort:_port];
            }
            break;
        default:
            break;
    }
}

@end
