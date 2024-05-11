//
//  MDLineViewController.m
//  xNetFuture
//
//  Created by huangrui on 2024/5/8.
//

#import "MDLineViewController.h"
#import "MDVPNTypeCell.h"
#import "MDVPNModel.h"
#import "MJExtension.h"
#import <Masonry/Masonry.h>

@interface MDLineViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) MDVPNModel *selectModel;

@end

@implementation MDLineViewController

- (void)viewDidLoad {
    self.title = @"请选择线路";
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[MDVPNTypeCell class] forCellReuseIdentifier:@"MDVPNTypeCellID"];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    NSUserDefaults *userDefaut = [NSUserDefaults standardUserDefaults];
    NSString *jsonModel = [userDefaut objectForKey:@"historyLine"];
    MDVPNModel *lastModel = [MDVPNModel mj_objectWithKeyValues:jsonModel.mj_keyValues];
    for (NSDictionary *dic in self.dataSource) {
        MDVPNModel *model = [MDVPNModel new];
        model.linkUrl = dic[@"linkUrl"];
        model.linkName = dic[@"linkName"];
        if ([lastModel.linkName isEqual:dic[@"linkName"]]) {
            model.isSelected = lastModel.isSelected;
        }
        model.isGlobel = [dic[@"linkUrl"] boolValue];
        model.isVless = [dic[@"isVless"] boolValue];
        [self.dataArray addObject:model];
        [self.tableView reloadData];
    }
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (NSArray *)dataSource {
    return  @[
        @{
            @"linkUrl":@"vmess://eyJ2IjoiMiIsInBzIjoidm1lc3NfdGNwIiwiYWRkIjoiMTgzLjI0MC4xNzkuMjA3IiwicG9ydCI6IjMwMTE4IiwiaWQiOiI0ZGY3MzA5ZC01OGI4LTQ1ODktYTJlZi0wN2ZmZTY3MGQ2NjUiLCJhaWQiOiIwIiwibmV0IjoidGNwIiwidHlwZSI6Im5vbmUiLCJob3N0IjoiIiwicGF0aCI6IiIsInRscyI6IiJ9",
            @"linkName":@"VMESS_TCP",
            @"isSelected":@false,
            @"isGlobel":@true,
            @"isVless":@false,
        },
        @{
            @"linkUrl":@"vless://2ddd7b52-082e-40e9-bd91-fd8f624d3438@137.184.94.157:23684?encryption=none&security=reality&type=tcp&sni=go.instance12580.site&fp=chrome&pbk=z1nOyx-hDuEqCOhvk7q4ti7Xxo8akTPn1KW6qrGVjgQ&sid=6ba85179e30d4fc2&flow=xtls-rprx-vision#2ddd7b52-vless_reality_vision",
            @"linkName":@"VLESS_REALITY_VISION",
            @"isSelected":@false,
            @"isGlobel":@true,
            @"isVless":@true,
        },
        @{
            @"linkUrl":@"vless://4df7309d-58b8-4589-a2ef-07ffe670d665@220.130.73.115:443?encryption=none&security=tls&type=ws&host=dpjdbsym35488455.xyz&sni=dpjdbsym35488455.xyz&fp=chrome&path=/81574b6b-c9d7-44a0-b83d-dad56e8cb501#vless-ws-tls",
            @"linkName":@"VLESS_WS_TLS",
            @"isSelected":@false,
            @"isGlobel":@true,
            @"isVless":@true,
        }
    ];
}

#pragma mark ------UITableViewDelegate&UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MDVPNTypeCell *normalCell = [tableView dequeueReusableCellWithIdentifier:@"MDVPNTypeCellID" forIndexPath:indexPath];
    MDVPNModel *model = [self.dataArray objectAtIndex:indexPath.row];
    normalCell.model = model;
    return normalCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    MDVPNModel *model = [self.dataArray objectAtIndex:indexPath.row];
    self.selectModel.isSelected = false;
    model.isSelected = true;
    self.selectModel = model;
    [tableView reloadData];
    NSUserDefaults *userDefaut = [NSUserDefaults standardUserDefaults];
    [userDefaut setObject:[model mj_JSONString] forKey:@"historyLine"];
    [userDefaut synchronize];
    if (self.block) {
        self.block(model);
    }
    [self.navigationController popViewControllerAnimated:true];
}


@end
