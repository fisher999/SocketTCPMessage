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
        if ([server bindWithIntervalFromFirstPort: (NSInteger) 2000 toEndPort: (NSInteger) 2046]) {
            while (true) {
                
            }
        }
    }
    return 0;
}
