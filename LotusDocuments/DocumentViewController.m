//
//  ViewController.m
//  LotusDocuments
//
//  Created by Sergey Mironchuk on 22.12.15.
//  Copyright © 2015 ATB-Market. All rights reserved.
//

#import "DocumentViewController.h"

#define URL_FOR_LOAD_ATTACHMENT @"http://iis-p.atbmarket.com/LotusWebAPI/home/GetAttachment/%@?attachment=%@"

@interface DocumentViewController () <UISplitViewControllerDelegate, 
        UITableViewDataSource, UITableViewDelegate, 
        QLPreviewControllerDataSource, QLPreviewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *tDate;
@property (weak, nonatomic) IBOutlet UILabel *number;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UITextView *text;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) NSString *filePath;

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
    self.tableView.delegate = self;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // for case 3 we use the QuickLook APIs directly to preview the document -
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    previewController.dataSource = self;
    previewController.delegate = self;

    // start previewing the document at the current section index
    previewController.currentPreviewItemIndex = indexPath.row;
    [[self navigationController] pushViewController:previewController animated:YES];
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

#pragma mark - QLPreviewControllerDataSource

// Returns the number of items that the preview controller should preview
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    return self.LotusDocument.Attachments.count;
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    // if the preview dismissed (done button touched), use this method to post-process previews
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.filePath];
    if (fileExists) {
        [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:NULL];
    }
}

// returns the item that the preview controller should preview
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    BOOL isDirectory;
    BOOL directoryExists = [[NSFileManager defaultManager] fileExistsAtPath:documentsDirectory isDirectory:&isDirectory];
    if (!directoryExists)
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    self.filePath = [documentsDirectory stringByAppendingPathComponent:self.LotusDocument.Attachments[idx]];

    NSString *urlString = [NSString stringWithFormat:
            URL_FOR_LOAD_ATTACHMENT,
            self.LotusDocument.UNID,
                    self.LotusDocument.Attachments[idx]];
    NSURL *documentURL = [NSURL URLWithString:
            [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSData *document = [NSData dataWithContentsOfURL:documentURL];
    NSURL *url = [NSURL fileURLWithPath:self.filePath];

    NSInteger len = [document length];
    BOOL result = [document writeToFile:self.filePath atomically:YES];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.filePath];

    return url;
}


@end
