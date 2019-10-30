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

@interface SMTCPSocketStreams () <NSStreamDelegate>
@end

@implementation SMTCPSocketStreams {
    __strong NSInputStream *_inputStream;
    __strong NSOutputStream *_outputStream;
    NSUInteger currentOffset;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = [[SMTCPMulticastDelegate alloc] init];
    }
    return self;
}

- (void)handleSocketEventsWithNativeHandle:(CFSocketNativeHandle) handle {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, handle, &readStream, &writeStream);
    if (readStream && writeStream) {
        CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        _inputStream = (__bridge_transfer NSInputStream *)readStream;
        _outputStream = (__bridge_transfer NSOutputStream *)writeStream;
        [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_inputStream open];
        [_outputStream open];
        _inputStream.delegate = self;
        CFRelease(readStream);
        CFRelease(writeStream);
        CFRunLoopRun();
    } else {
        close(handle);
    }
}

- (void)writeMessage:(NSString *)message {
    NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t *dataBytes = (uint8_t *)[messageData bytes];
    dataBytes += currentOffset;
    NSUInteger length = [messageData length] - currentOffset > 1024 ? 1024 : [messageData length] - currentOffset;
    NSUInteger sentLength = [_outputStream write: dataBytes maxLength: length];
    if (sentLength > 0) {
        currentOffset += sentLength;
        if (currentOffset == [messageData length]) {
            currentOffset = 0;
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
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)dealloc {
    [self close];
}

#pragma mark: -SMTCPSocketServerDelegate

- (void)SMTCPServer:(SMTCPServer *)server didSendMessage:(NSString *)message {
    [self writeMessage:message];
}

@end


@implementation SMTCPSocketStreams (NSStreamDelegate)

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable:
            if ([aStream isKindOfClass:[NSInputStream class]]) {
                NSString *message = [self readFromInputStream:(NSInputStream *) aStream];
                [_delegate SMTCPSocketStreams:self didReceivedMessage:message];
            }
            break;
        default:
            break;
    }
}

@end
