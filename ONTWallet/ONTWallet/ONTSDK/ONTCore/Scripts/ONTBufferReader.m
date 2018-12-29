//
//  ONTBufferReader.m
//  ONTWallet
//
//  Created by Yuzhiyou on 2018/12/21.
//  Copyright © 2018 zhangyutao. All rights reserved.
//

#import "ONTBufferReader.h"
#import "NSData+Extend.h"

@interface ONTBufferReader()
@property (nonatomic,strong) NSData *data;
@property (nonatomic,assign) NSInteger offset;
@end

@implementation ONTBufferReader

-(instancetype)initWithData:(NSData *)data{
    self = [super init];
    if (self) {
        self.data = data;
        self.offset = 0;
    }
    return self;
}
-(uint8_t)readUInt8{
    uint8_t v = [self.data UInt8AtOffset:self.offset];
    self.offset += 1;
    return v;
}
-(uint16_t)readUInt16LE{
    uint16_t v = [self.data UInt16AtOffset:self.offset];
    self.offset += 2;
    return v;
}
-(uint32_t)readUInt32LE{
    uint32_t v = [self.data UInt32AtOffset:self.offset];
    self.offset += 4;
    return v;
}
-(uint64_t)readUInt64LE{
    uint64_t v = [self.data UInt64AtOffset:self.offset];
    self.offset += 8;
    return v;
}


-(NSData *)forward{
    NSUInteger length = 0 ;
    NSData *d = [self.data dataAtOffset:self.offset length:&length];
    self.offset += length;
    return d;
}
@end
