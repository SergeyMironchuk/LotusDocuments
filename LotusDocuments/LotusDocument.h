//
//  LotusDocument.h
//  LotusDocuments
//
//  Created by Sergey Mironchuk on 22.12.15.
//  Copyright © 2015 ATB-Market. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LotusDocument : NSObject
@property (nonatomic, strong) NSString *UNID;
@property (nonatomic, strong) NSString *TDate;
@property (nonatomic, strong) NSString *Refer;
@property (nonatomic, strong) NSString *Text;
@property (nonatomic, strong) NSString *Number;
@property (nonatomic, strong) NSString *Author;
@property (nonatomic, strong) NSArray *Attachments;
@property (nonatomic, strong) NSString *Version;
@end
