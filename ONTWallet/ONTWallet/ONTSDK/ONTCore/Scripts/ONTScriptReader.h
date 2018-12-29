//
//  ONTScriptReader.h
//  ONTWallet
//
//  Created by Yuzhiyou on 2018/12/21.
//  Copyright © 2018 zhangyutao. All rights reserved.
//

#import "ONTBufferReader.h"
#import "NSMutableData+ONTScriptBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface ONTScriptReader : ONTBufferReader

-(ONT_OPCODE)readOpcode;
-(BOOL)readBool;
-(NSData *)readData;
-(NSInteger)readVarInt;
-(NSData *)readVarData;

@end

NS_ASSUME_NONNULL_END
