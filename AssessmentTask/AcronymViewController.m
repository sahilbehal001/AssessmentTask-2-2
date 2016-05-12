//
//  ViewController.m
//  AssessmentTask
//
//  Created by Sahil Behal on 5/10/16.
//  Copyright © 2016 Sahil Behal. All rights reserved.
//

#import "AcronymViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@interface AcronymViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *acronymsTxtFld;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
- (IBAction)searchBtnPressed:(id)sender;

@end

@implementation AcronymViewController{
    NSArray *result;
    MBProgressHUD *hud;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tblView.delegate = self;
    _tblView.dataSource = self;
    
    result = [[NSArray alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startBusyIndicator) name:@"ShowProgressIndicatorEvent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopBusyIndicator) name:@"HideProgressIndicatorEvent" object:nil];
    
}


#pragma mark - Table View

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return result.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = [result objectAtIndex:indexPath.row];
    
    return cell;
}


- (IBAction)searchBtnPressed:(id)sender {
    if (!_acronymsTxtFld.text.length) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                       message:@"Please enter Acronym."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else{
    
    [_acronymsTxtFld resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowProgressIndicatorEvent" object:self];
    
    [self serviceGetRequest];
    }
}


#pragma mark - GET Request

-(void)serviceGetRequest{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
   
    [manager GET:[NSString stringWithFormat:@"http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=%@",self.acronymsTxtFld.text ] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        result = [[[responseObject valueForKey:@"lfs"] valueForKey:@"lf"] objectAtIndex:0];
        [self.tblView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HideProgressIndicatorEvent" object:self];
    }
         failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

#pragma mark - MBProgressHUD

-(void)startBusyIndicator{
    
    UIWindow *windowForHud = [[UIApplication sharedApplication] delegate].window;
    hud = [MBProgressHUD showHUDAddedTo:windowForHud animated:YES];
    hud.backgroundColor = [UIColor darkGrayColor];
    hud.label.text = @"Getting...";
    hud.minShowTime = 0.0;
    
    
}

-(void)stopBusyIndicator{
    
    UIWindow *windowForHud = [[UIApplication sharedApplication] delegate].window;
    [MBProgressHUD hideHUDForView:windowForHud animated:YES];
    [hud hideAnimated:YES];
}
@end
