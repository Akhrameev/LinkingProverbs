//
//  FirstViewController.m
//  LinkedProverbs
//
//  Created by Pavel Akhrameev on 30.01.14.
//  Copyright (c) 2014 Pavel Akhrameev. All rights reserved.
//

#import "FirstViewController.h"
#import "UPProverbCollectionCell.h"
#import "DAO.h"
#import "Proverb.h"

@interface FirstViewController () {
    NSArray *proverbs;
}

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proverbsUpdated:) name:DAOProverbsUpdated object:nil];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) viewWillAppear:(BOOL)animated {
    [[DAO sharedInstance] proverbsWithReload:NO];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"proverbCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if ([cell isKindOfClass:[UPProverbCollectionCell class]]) {
        NSAssert(proverbs.count >= indexPath.row, @"Ошибка: индекс за пределами массива");
        Proverb *proverb = [proverbs objectAtIndex:indexPath.row];
        UPProverbCollectionCell *proverbCell = (UPProverbCollectionCell *)cell;
        proverbCell.nameLabel.text = proverb.text;
        proverbCell.textLabel.text = proverb.descriptionText;
    }
    return cell;
}

- (void) proverbsUpdated:(NSNotification *)note {
    NSArray *updatedProverbs = note.object;
    if (!updatedProverbs || [updatedProverbs isKindOfClass:[NSArray class]]) {
        proverbs = updatedProverbs;
        [self.collectionView reloadData];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return proverbs.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
@end
