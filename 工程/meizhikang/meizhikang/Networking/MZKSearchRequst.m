//
//  MZKSearchRequst.m
//  meizhikang
//
//  Created by 刘向宏 on 16/1/13.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import "BaseHTTPRequestOperationManager.h"
#import "MZKSearchRequst.h"
#import "JSONKit.h"

@implementation MZKSearchRequst

+(void)SearchGroupWithParameters:(NSString *)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure{
    NSString *urlStr = [NSString stringWithFormat:@"http://182.150.44.21:8666/axis2/services/GroupService/getGroups?groupName=%@",parameters];
    urlStr= [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError) {
            failure([NSError errorWithDomain:connectionError.localizedDescription code:0 userInfo:nil]);
        }
        else{
            NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            str = [str stringByReplacingOccurrencesOfString:@"<ns:getGroupsResponse xmlns:ns=\"http://service.webservice.mzk.com\"><ns:return>" withString:@""];
            str = [str stringByReplacingOccurrencesOfString:@"</ns:return></ns:getGroupsResponse>" withString:@""];
            id object = [str objectFromJSONString];
            if (object) {
                success(object);
            }
            else{
                failure([NSError errorWithDomain:@"服务器返回错误" code:0 userInfo:nil]);
            }
        }
    }];
}

+(void)SearchMemberWithParameters:(NSString *)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure{
    NSString *urlStr = [NSString stringWithFormat:@"http://182.150.44.21:8666/axis2/services/MemberService/getMembers?%@",parameters];
    urlStr= [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError) {
            failure([NSError errorWithDomain:connectionError.localizedDescription code:0 userInfo:nil]);
        }
        else{
            NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            str = [str stringByReplacingOccurrencesOfString:@"<ns:getMembersResponse xmlns:ns=\"http://service.webservice.mzk.com\"><ns:return>" withString:@""];
            str = [str stringByReplacingOccurrencesOfString:@"</ns:return></ns:getMembersResponse>" withString:@""];
            id object = [str objectFromJSONString];
            if (object) {
                success(object);
            }
            else{
                failure([NSError errorWithDomain:@"服务器返回错误" code:0 userInfo:nil]);
            }
        }
    }];
}
@end
