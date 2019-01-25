// AFJSONRPCClient.m
// 
// Created by wiistriker@gmail.com
// Copyright (c) 2013 JustCommunication
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ONTAFJSONRPCClient.h"
#import "AFHTTPRequestOperation.h"

#import <objc/runtime.h>

NSString * const ONTAFJSONRPCErrorDomain = @"com.alamofire.networking.json-rpc";

static NSString * ONTAFJSONRPCLocalizedErrorMessageForCode(NSInteger code) {
    switch(code) {
        case -32700:
            return @"Parse Error";
        case -32600:
            return @"Invalid Request";
        case -32601:
            return @"Method Not Found";
        case -32602:
            return @"Invalid Params";
        case -32603:
            return @"Internal Error";
            
        case 41001:
            return @"SESSION_EXPIRED";
        case 41002:
            return @"SERVICE_CEILING";
        case 41003:
            return @"ILLEGAL_DATAFORMAT";
        case 41004:
            return @"INVALID_VERSION";
        case 42001:
            return @"INVALID_METHOD";
        case 42002:
            return @"INVALID_PARAMS";
        case 43001:
            return @"INVALID_TRANSACTION";
        case 43002:
            return @"INVALID_ASSET";
        case 43003:
            return @"INVALID_BLOCK";
        case 44001:
            return @"UNKNOWN_TRANSACTION";
        case 44002:
            return @"UNKNOWN_ASSET";
        case 44003:
            return @"UNKNOWN_BLOCK";
        case 45001:
            return @"INTERNAL_ERROR";
        case 47001:
            return @"SMARTCODE_ERROR";
            
        default:
            return @"Server Error";
    }
}

@interface ONTAFJSONRPCProxy : NSProxy
- (id)initWithClient:(ONTAFJSONRPCClient *)client
            protocol:(Protocol *)protocol;
@end

#pragma mark -

@interface ONTAFJSONRPCClient ()
@property (readwrite, nonatomic, strong) NSURL *endpointURL;
@end

@implementation ONTAFJSONRPCClient

+ (instancetype)clientWithEndpointURL:(NSURL *)URL {
    return [[self alloc] initWithEndpointURL:URL];
}

- (id)initWithEndpointURL:(NSURL *)URL {
    NSParameterAssert(URL);

    self = [super initWithBaseURL:URL];
    if (!self) {
        return nil;
    }

    self.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"application/json-rpc", @"application/jsonrequest", nil];

    self.endpointURL = URL;

    return self;
}

- (void)invokeMethod:(NSString *)method
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self invokeMethod:method withParameters:@[] success:success failure:failure];
}

- (void)invokeMethod:(NSString *)method
      withParameters:(id)parameters
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self invokeMethod:method withParameters:parameters requestId:@(1) success:success failure:failure];
}

- (void)invokeMethod:(NSString *)method
      withParameters:(id)parameters
           requestId:(id)requestId
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self requestWithMethod:method parameters:parameters requestId:requestId];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                parameters:(id)parameters
                                 requestId:(id)requestId
{
    NSParameterAssert(method);

    if (!parameters) {
        parameters = @[];
    }

    NSAssert([parameters isKindOfClass:[NSDictionary class]] || [parameters isKindOfClass:[NSArray class]], @"Expect NSArray or NSDictionary in JSONRPC parameters");

    if (!requestId) {
        requestId = @(1);
    }

    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    payload[@"jsonrpc"] = @"2.0";
    payload[@"method"] = method;
    payload[@"params"] = parameters;
    payload[@"id"] = [requestId description];

    return [self.requestSerializer requestWithMethod:@"POST" URLString:[self.endpointURL absoluteString] parameters:payload error:nil];
}

#pragma mark - AFHTTPClient
/*
- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [super HTTPRequestOperationWithRequest:urlRequest success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"AFHTTPClient = %@", responseObject);
        NSInteger code = 0;
        NSString *message = nil;
        id data = nil;

        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            id result = responseObject[@"result"];
            id error = responseObject[@"error"];
            
            if (result && result != [NSNull null]) {
                if (success) {
                    success(operation, result);
                    return;
                }
            } else if (error && error != [NSNull null]) {
                if ([error isKindOfClass:[NSDictionary class]]) {
                    if (error[@"code"]) {
                        code = [error[@"code"] integerValue];
                    }

                    if (error[@"message"]) {
                        message = error[@"message"];
                    } else if (code) {
                        message = ONTAFJSONRPCLocalizedErrorMessageForCode(code);
                    }

                    data = error[@"data"];
                } else {
                    message = NSLocalizedStringFromTable(@"Unknown Error", @"AFJSONRPCClient", nil);
                }
            } else {
                message = NSLocalizedStringFromTable(@"Unknown JSON-RPC Response", @"AFJSONRPCClient", nil);
            }
        } else {
            message = NSLocalizedStringFromTable(@"Unknown JSON-RPC Response", @"AFJSONRPCClient", nil);
        }

        if (failure) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            if (message) {
                userInfo[NSLocalizedDescriptionKey] = message;
            }

            if (data) {
                userInfo[@"data"] = data;
            }

            NSError *error = [NSError errorWithDomain:ONTAFJSONRPCErrorDomain code:code userInfo:userInfo];

            failure(operation, error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
    }];
}
 */

// ONT RPC 返回结构
/*
{
    desc = SUCCESS;
    error = 0;
    id = 3;
    jsonrpc = "2.0";
    result = 1601354130;
}
 */
- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [super HTTPRequestOperationWithRequest:urlRequest success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"AFHTTPClient = %@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            id result = responseObject[@"result"];
            id error = responseObject[@"error"];
            id des = responseObject[@"desc"];
            
            if ([error isKindOfClass:[NSNumber class]]) {
                NSNumber *errorCode = (NSNumber *)error;
                NSInteger code = errorCode.integerValue;
                if (code == 0) { // Success
                    if (success) {
                        success(operation, result);
                    }
                } else {
                    if (failure) {
                        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                        userInfo[NSLocalizedDescriptionKey] = [NSString stringWithFormat:@"%@:%@", des, result];
                        NSError *error = [NSError errorWithDomain:ONTAFJSONRPCErrorDomain code:code userInfo:userInfo];
                        failure(operation, error);
                    }
                }
            } else {
                if (failure) {
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                    userInfo[NSLocalizedDescriptionKey] = [NSString stringWithFormat:@"%@:%@", des, result];
                    NSError *error = [NSError errorWithDomain:ONTAFJSONRPCErrorDomain code:-1 userInfo:userInfo];
                    failure(operation, error);
                }
            }
        } else {
            if (failure) {
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                if (responseObject) {
                    userInfo[NSLocalizedDescriptionKey] = [NSString stringWithFormat:@"%@", responseObject];
                } else {
                    userInfo[NSLocalizedDescriptionKey] = NSLocalizedStringFromTable(@"Unknown JSON-RPC Response", @"AFJSONRPCClient", nil);
                }
                NSError *error = [NSError errorWithDomain:ONTAFJSONRPCErrorDomain code:-1 userInfo:userInfo];
                failure(operation, error);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
    }];
}

- (id)proxyWithProtocol:(Protocol *)protocol {
    return [[ONTAFJSONRPCProxy alloc] initWithClient:self protocol:protocol];
}

@end

#pragma mark -

typedef void (^ONTAFJSONRPCProxySuccessBlock)(id responseObject);
typedef void (^ONTAFJSONRPCProxyFailureBlock)(NSError *error);

@interface ONTAFJSONRPCProxy ()
@property (readwrite, nonatomic, strong) ONTAFJSONRPCClient *client;
@property (readwrite, nonatomic, strong) Protocol *protocol;
@end

@implementation ONTAFJSONRPCProxy

- (id)initWithClient:(ONTAFJSONRPCClient*)client
            protocol:(Protocol *)protocol
{
    self.client = client;
    self.protocol = protocol;

    return self;
}

- (BOOL)respondsToSelector:(SEL)selector {
    struct objc_method_description description = protocol_getMethodDescription(self.protocol, selector, YES, YES);

    return description.name != NULL;
}

- (NSMethodSignature *)methodSignatureForSelector:(__unused SEL)selector {
    // 0: v->RET || 1: @->self || 2: :->SEL || 3: @->arg#0 (NSArray) || 4,5: ^v->arg#1,2 (block)
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:@^v^v"];

    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSParameterAssert(invocation.methodSignature.numberOfArguments == 5);

    NSString *RPCMethod = [NSStringFromSelector([invocation selector]) componentsSeparatedByString:@":"][0];

    __unsafe_unretained id arguments;
    __unsafe_unretained ONTAFJSONRPCProxySuccessBlock unsafeSuccess;
    __unsafe_unretained ONTAFJSONRPCProxyFailureBlock unsafeFailure;

    [invocation getArgument:&arguments atIndex:2];
    [invocation getArgument:&unsafeSuccess atIndex:3];
    [invocation getArgument:&unsafeFailure atIndex:4];
    
    [invocation invokeWithTarget:nil];

    __strong ONTAFJSONRPCProxySuccessBlock strongSuccess = [unsafeSuccess copy];
    __strong ONTAFJSONRPCProxyFailureBlock strongFailure = [unsafeFailure copy];

    [self.client invokeMethod:RPCMethod withParameters:arguments success:^(__unused AFHTTPRequestOperation *operation, id responseObject) {
        if (strongSuccess) {
            strongSuccess(responseObject);
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        if (strongFailure) {
            strongFailure(error);
        }
    }];
}

@end
