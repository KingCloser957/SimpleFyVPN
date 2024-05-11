//
//  ViewController.m
//  xNetFuture-iOS
//
//  Created by 杨雨东 on 2023/8/17.
//

#import "ViewController.h"
#import "YDVPNManager.h"
#import <NetworkExtension/NetworkExtension.h>
#import "YDFutureManager.h"
#import "MDVPNTypeCell.h"
#import "MDLineViewController.h"
#import "MJExtension.h"

@interface ViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *protocolTextField;
@property (weak, nonatomic) IBOutlet UILabel *statusLab;
@property (weak, nonatomic) IBOutlet UIButton *startConnectButton;
@property (weak, nonatomic) IBOutlet UISwitch *Switch;
@property (weak, nonatomic) IBOutlet UILabel *linkNameLb;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"open" forState:UIControlStateNormal];
    [btn setTitle:@"open" forState:UIControlStateSelected];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(openVpn) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
    
    self.protocolTextField.delegate = self;
    
    NSString *rayV = [YDFutureManager version];
    NSString *rayEnv = [YDFutureManager GetV2Env];
    NSLog(@"X-Ray版本 %@", rayV);
    NSLog(@"X-Ray tunnel_version 版本 %@", rayEnv);
    
    [YDVPNStatus shareInstance].vpnStatus = ^(VPNStatus status) {
        switch (status) {
            case on:{
                self.statusLab.textColor = [UIColor systemGreenColor];
                self.statusLab.text = @"Connected";
                
                [self.startConnectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
                [self.startConnectButton setTitleColor:UIColor.redColor forState:UIControlStateNormal];
            }
                break;
                
            case connecting: {
                self.statusLab.textColor = [UIColor systemOrangeColor];
                self.statusLab.text = @"Connecting";
            }
                break;
                
            case off:{
                self.statusLab.textColor = [UIColor systemRedColor];
                self.statusLab.text = @"Disconnected";
                [self.startConnectButton setTitle:@"Connect" forState:UIControlStateNormal];
                [self.startConnectButton setTitleColor:UIColor.systemGreenColor forState:UIControlStateNormal];
            }
                break;
        
            case disconnecting: {
                self.statusLab.text = @"Disconnecting";
                self.statusLab.textColor = [UIColor systemRedColor];
            }
                break;
                
            default:
                break;
        }
    };
    
    NSUserDefaults *userDefaut = [NSUserDefaults standardUserDefaults];
    if ([userDefaut objectForKey:@"historyLine"] == nil) {
        self.protocolTextField.text = @"vmess://eyJ2IjoiMiIsInBzIjoidm1lc3NfdGNwIiwiYWRkIjoiMTgzLjI0MC4xNzkuMjA3IiwicG9ydCI6IjMwMTE4IiwiaWQiOiI0ZGY3MzA5ZC01OGI4LTQ1ODktYTJlZi0wN2ZmZTY3MGQ2NjUiLCJhaWQiOiIwIiwibmV0IjoidGNwIiwidHlwZSI6Im5vbmUiLCJob3N0IjoiIiwicGF0aCI6IiIsInRscyI6IiJ9";
        self.linkNameLb.text = @"VMESS_TCP";
    } else {
        NSString *linkUri = [userDefaut objectForKey:@"historyLine"];
        MDVPNModel *model = [MDVPNModel mj_objectWithKeyValues:linkUri.mj_keyValues];
        self.protocolTextField.text = model.linkUrl;
        self.linkNameLb.text = model.linkName;
    }
}

- (void)openVpn {
    __weak ViewController *weakSelf = self;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.protocolTextField resignFirstResponder];
}
- (IBAction)chooseLine:(UIButton *)sender {
    MDLineViewController *lineVc = [[MDLineViewController alloc] init];
    lineVc.block = ^(MDVPNModel * _Nonnull model) {
        self->_protocolTextField.text = model.linkUrl;
        self->_linkNameLb.text = model.linkName;
    };
    [self.navigationController pushViewController:lineVc animated:true];
}
- (IBAction)openOrClose:(UISwitch *)sender {
    
}

- (IBAction)startConnectButtonClick:(id)sender {
    NSUserDefaults *userDefaut = [NSUserDefaults standardUserDefaults];
    if ([userDefaut objectForKey:@"historyLine"] == nil) {
        MDLineViewController *lineVc = [[MDLineViewController alloc] init];
        lineVc.block = ^(MDVPNModel * _Nonnull model) {
            self->_protocolTextField.text = model.linkUrl;
            self->_linkNameLb.text = model.linkName;
        };
        [self.navigationController pushViewController:lineVc animated:true];
        return;
    }
    NSString *linkUri = [userDefaut objectForKey:@"historyLine"];
    MDVPNModel *model = [MDVPNModel mj_objectWithKeyValues:linkUri.mj_keyValues];
    NSString *title = [self.startConnectButton titleForState:UIControlStateNormal];
    if ([title isEqualToString:NSLocalizedString(@"Connect", nil)]) {
        NSString *uri = model.linkUrl;
        BOOL isGlobalMode = YES;
        
        YDConnection *connection = [[YDConnection alloc] init];
        connection.isGlobal = isGlobalMode;
        connection.vpnServerAddress = uri;
        connection.type = 0;
        NSDictionary *providerConfiguration = @{@"type":@(0), @"uri":uri, @"global":@(self.Switch.isOn)};
        [[YDVPNManager sharedManager] startWithVpnConfigDir:providerConfiguration completion:^(NETunnelProviderManager * _Nonnull manager, ErrorCode error) {
            
        }];
    } else {
        [[YDVPNManager sharedManager]stop];
    }
}

- (IBAction)echoButton:(id)sender {
    NSDictionary *echo = @{@"type":@1};
    [YDVPNManager loadProviderManagerWithCompletion:^(NETunnelProviderManager * _Nullable manager) {
        NETunnelProviderSession *session = (NETunnelProviderSession *)manager.connection;
        [session sendProviderMessage:[NSJSONSerialization dataWithJSONObject:echo options:(NSJSONWritingPrettyPrinted) error:nil] returnError:nil responseHandler:^(NSData * _Nullable responseData) {
            NSString *x = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", x);
        }];
    }];
}


@end
