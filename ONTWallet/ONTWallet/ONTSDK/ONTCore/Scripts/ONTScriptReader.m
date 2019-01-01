//
//  ONTScriptReader.m
//  ONTWallet
//
//  Created by Yuzhiyou on 2018/12/21.
//  Copyright © 2018 zhangyutao. All rights reserved.
//

#import "ONTScriptReader.h"

@implementation ONTScriptReader
-(ONT_OPCODE)readOpcode{
    return [self readUInt8];
}
-(BOOL)readBool{
    ONT_OPCODE code = [self readOpcode];
    return code == ONT_OPCODE_PUSHT;
}
-(NSData *)readData{
    ONT_OPCODE code = [self readOpcode];
    
    NSUInteger len = 0;
    if (code == ONT_OPCODE_PUSHDATA4) {
        len = [self readUInt32LE];
    }else if (code == ONT_OPCODE_PUSHDATA2) {
        len = [self readUInt16LE];
    }else if (code == ONT_OPCODE_PUSHDATA1) {
        len = [self readUInt8];
    }else if (code <= ONT_OPCODE_PUSHBYTES75 && code >= ONT_OPCODE_PUSHBYTES1) {
        len = code - ONT_OPCODE_PUSHBYTES1 + 1;
    }else{
        return nil;
    }
    return [self forward];
}
-(NSInteger)readVarInt{
    NSUInteger len = [self readUInt8];
    if(len == 0xFD) {
        return [self readUInt16LE];
    }else if(len == 0xFE){
        return [self readUInt32LE];
    } else if(len == 0xFF) {
        return [self readUInt64LE];
    }
    return len;
}
-(NSData *)readVarData{
    return [self forward];
}
@end
