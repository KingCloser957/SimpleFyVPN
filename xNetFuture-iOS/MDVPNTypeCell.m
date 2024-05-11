//
//  MDVPNTypeCell.m
//  xNetFuture
//
//  Created by huangrui on 2024/5/7.
//

#import "MDVPNTypeCell.h"
#import "JSTool.h"
#import "UIColor+DD.h"
#import <Masonry/Masonry.h>
#import "YDFutureManager.h"

@interface MDVPNTypeCell ()

@property (nonatomic,strong)UIButton *linkIconBtn;
@property (nonatomic,strong)UILabel *linkServiceLb;
@property (nonatomic,strong)UILabel *linkNameLb;
@property (nonatomic,strong)UILabel *pingLb;
@property (nonatomic,strong)UIView *lineView;

@end

@implementation MDVPNTypeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
        [self setupConstrains];
    }
    return  self;
}

- (void)setupViews {
    
    _linkIconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_linkIconBtn setImage:[UIImage imageNamed:@"off"] forState:UIControlStateNormal];
    [_linkIconBtn setImage:[UIImage imageNamed:@"on"] forState:UIControlStateSelected];
    [_linkIconBtn addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
    
    _linkServiceLb = [JSTool lableWithFrame:CGRectZero Text:@"" textColor:[UIColor colorWithHex:0x000000] Alignment:NSTextAlignmentLeft Font:[UIFont systemFontOfSize:18]];
    
    _linkNameLb = [JSTool lableWithFrame:CGRectZero Text:@"" textColor:[UIColor darkGrayColor] Alignment:NSTextAlignmentLeft Font:[UIFont systemFontOfSize:12]];
    
    _pingLb = [JSTool lableWithFrame:CGRectZero Text:@"" textColor:[UIColor colorWithHex:0x439A00] Alignment:NSTextAlignmentLeft Font:[UIFont systemFontOfSize:16]];
    
    _lineView = [UIView new];
    _lineView.backgroundColor = [UIColor colorWithHex:0xEFEFEF];
    
    [self.contentView addSubview:_linkIconBtn];
    [self.contentView addSubview:_linkServiceLb];
    [self.contentView addSubview:_linkNameLb];
    [self.contentView addSubview:_pingLb];
    [self.contentView addSubview:_lineView];
}

- (void)setupConstrains {
    
    [_linkIconBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView.mas_leading).offset(16);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.height.equalTo(@20);
        make.width.equalTo(@20);
    }];
    
    [_linkServiceLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.linkIconBtn.mas_trailing).offset(16);
        make.top.equalTo(self.contentView.mas_top).offset(8);
        make.height.equalTo(@20);
    }];
    
    [_linkNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_linkServiceLb.mas_leading);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-8);
        make.height.equalTo(@10);
    }];
    
    [_pingLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-16);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.height.equalTo(@14);
    }];
    
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView.mas_leading).offset(16);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-6);
        make.height.equalTo(@1);
        make.bottom.equalTo(self.contentView.mas_bottom);
    }];
}

- (void)setModel:(MDVPNModel *)model {
    _model = model;
    [self configLinkUrlWithModel:model complete:^(NSString *adress, NSNumber *port) {
        self.linkServiceLb.text = [NSString stringWithFormat:@"%@:%@",adress,port];
    }];
    self.linkNameLb.text = model.linkName;
    self.pingLb.text = [NSString stringWithFormat:@"%ums",arc4random() % 100];
    if (model.isSelected) {
        [self.linkIconBtn setSelected:true];
    } else {
        [self.linkIconBtn setSelected:false];
    }
}

- (void)configLinkUrlWithModel:(MDVPNModel *)model complete:(void (^) (NSString *adress,NSNumber *port))complteHandler
{
    if (model.isVless) {
        NSArray <NSString *> *info = [model.linkUrl componentsSeparatedByString:@"@"];
        if (info.count < 2) {
            return;
        }
        
        NSArray <NSString *>*config = [info[1] componentsSeparatedByString:@"?"];
        if (config.count < 2) {
            return ;
        }
        
        NSArray <NSString *>*ipAddress = [config[0] componentsSeparatedByString:@":"];
        if (ipAddress.count < 2) {
            return ;
        }
        NSString *address = ipAddress[0];
        NSNumber *port = @([ipAddress[1] integerValue]);
        
        NSArray <NSString *> *suffix = [config[1] componentsSeparatedByString:@"#"];
        
        if (suffix.count < 2) {
            return ;
        }
        complteHandler(address,port);
    } else {
        
        NSArray <NSString *>*list = [model.linkUrl componentsSeparatedByString:@"//"];
        if (list.count != 2) {
            return ;
        }
        NSData *payload = [[NSData alloc] initWithBase64EncodedString:list[1] options:0];
        NSError *error;
        NSDictionary *info = [NSJSONSerialization JSONObjectWithData:payload options:NSJSONReadingMutableContainers error:&error];
        if (error) {
            NSLog(@"%@", error);
            return ;
        }
        NSString *address = info[@"add"];
        NSNumber *port = info[@"port"];
        if (port && ![port isKindOfClass:NSNumber.class]) {
            port = @(port.integerValue);
        }
        complteHandler(address,port);
    }
}

- (void)tapAction
{
    
}

@end
