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

@interface SMTCPSocketStreams () <NSStreamDelegate, SMTCPServerDelegate>
@end

@implementation SMTCPSocketStreams {
    __strong NSInputStream *_inputStream;
    __strong NSOutputStream *_outputStream;
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
    uint32_t length = (uint32_t)htonl([messageData length]);
    [_outputStream write:(uint8_t *)&length maxLength:4];
    [_outputStream write:[messageData bytes] maxLength:length];
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
