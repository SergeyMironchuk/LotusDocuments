//
//  ViewController.m
//  LotusDocuments
//
//  Created by Sergey Mironchuk on 22.12.15.
//  Copyright © 2015 ATB-Market. All rights reserved.
//

#import "DocumentViewController.h"

@interface DocumentViewController () <UISplitViewControllerDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *tDate;
@property (weak, nonatomic) IBOutlet UILabel *number;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UITextView *text;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DocumentViewController

- (void)setLotusDocument:(LotusDocument *)lotusDocument
{
    _LotusDocument = lotusDocument;
    [self setDocument];
    [self scrollText:YES];
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self setDocument];
}

- (void)setDocument {
    self.tDate.text = self.LotusDocument.TDate;
    self.number.text = self.LotusDocument.Number;
    self.author.text = self.LotusDocument.Author;
    self.text.text = self.LotusDocument.Text;
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [self scrollText:animated];
}

- (void)viewDidLayoutSubviews {
    if (!UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
        self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
}

- (void)scrollText:(BOOL)animated {
    [self.text setContentOffset:CGPointZero animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.LotusDocument.Attachments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileName Cell" forIndexPath:indexPath];

    // Configure the cell...
    NSString *fileName = self.LotusDocument.Attachments[indexPath.row];
    cell.textLabel.text = fileName;
    cell.detailTextLabel.text = fileName;

    return cell;
}

#pragma mark - SplitViewController delegate

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverPresentationController *)pc {
    barButtonItem.title = aViewController.title;
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    self.navigationItem.leftBarButtonItem = nil;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation {
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation);
    // (UIDeviceOrientationIsPortrait(orientation) || UIDeviceOrientationIsLandscape(orientation)) || self.portraitOrientation;
}

@end
