//
//  LotusDocument.m
//  LotusDocuments
//
//  Created by Sergey Mironchuk on 22.12.15.
//  Copyright © 2015 ATB-Market. All rights reserved.
//

#import "LotusDocument.h"

@implementation LotusDocument
- (NSString *)Text {
    if ([_Text isKindOfClass:[NSNull class]]) return @"Без текста";
    return _Text;
}

@end
