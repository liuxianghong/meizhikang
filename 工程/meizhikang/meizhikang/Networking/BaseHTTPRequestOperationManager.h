//
//  BaseHTTPRequestOperationManager.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/30.
//
//

#import "AFHTTPRequestOperationManager.h"

@interface BaseHTTPRequestOperationManager : AFHTTPRequestOperationManager
+ (BaseHTTPRequestOperationManager *)sharedManager;
- (void)defaultHTTPWithMethod:(NSString *)method WithParameters:(id)parameters  post:(BOOL)bo success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

- (void)filePostWithUrl:(NSString *)urlString WithParameters:(NSData *)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
@end
