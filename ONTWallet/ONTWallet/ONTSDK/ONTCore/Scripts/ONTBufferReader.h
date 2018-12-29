//
//  ONTBufferReader.h
//  ONTWallet
//
//  Created by Yuzhiyou on 2018/12/21.
//  Copyright © 2018 zhangyutao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ONTBufferReader : NSObject
-(instancetype)initWithData:(NSData *)data;

-(uint8_t)readUInt8;
-(uint16_t)readUInt16LE;
-(uint32_t)readUInt32LE;
-(uint64_t)readUInt64LE;

-(NSData *)forward;
@end

NS_ASSUME_NONNULL_END
