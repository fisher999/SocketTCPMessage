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
#import "GCDConcurrency.h"

@interface SMTCPSocketStreams () <NSStreamDelegate>

@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;
@property (assign, nonatomic) NSUInteger currentOffset;

@end

@implementation SMTCPSocketStreams
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
    if (!(_inputStream && _outputStream)) {
        return;
    }
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream open];
    [_outputStream open];
    _inputStream.delegate = self;
    _isConnected = YES;
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
    if (!(_inputStream && _outputStream)) {
        return;
    }
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream open];
    [_outputStream open];
    _inputStream.delegate = self;
    _isConnected = YES;
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
    __weak SMTCPSocketStreams *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
        uint8_t *dataBytes = (uint8_t *)[messageData bytes];
        dataBytes += [weakSelf currentOffset];
        NSUInteger length = [messageData length] - [weakSelf currentOffset] > 1024 ? 1024 : [messageData length] - [weakSelf currentOffset];
        sleep(3);
        NSUInteger sentLength = [[weakSelf outputStream] write: dataBytes maxLength: length];
        NSLog(@"message: %@", message);
        if (sentLength > 0) {
            weakSelf.currentOffset += sentLength;
            if (weakSelf.currentOffset == [messageData length]) {
                weakSelf.currentOffset = 0;
            }
        }
    });
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
    return total;
}


- (void)close {
    [_inputStream close];
    [_outputStream close];
    _isConnected = NO;
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
                __weak SMTCPSocketStreams *weakSelf = self;
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
                    NSString *message = [weakSelf readFromInputStream:(NSInputStream *) aStream];
                    [[weakSelf delegate] SMTCPSocketStreams:weakSelf didReceivedMessage:message atIp:[weakSelf ip] atPort:[weakSelf port]];
                });
            }
            break;
        default:
            break;
    }
}

@end
