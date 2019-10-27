//
//  main.m
//  SocketMessageServer
//
//  Created by Victor on 26.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMTCPServer.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        SMTCPServer *server = [[SMTCPServer alloc] init];
        [server bindWithPort:2000];
        [server listen];
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
