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
#import "UIColor+MLPFlatColors.h"

@interface FirstViewController () {
    NSArray *proverbs;
    NSMutableSet *selectedProverbs;
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
    proverbs = nil;
    selectedProverbs = nil;
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
        Proverb *proverb = [self proverbAtIndexPath:indexPath];
        UPProverbCollectionCell *proverbCell = (UPProverbCollectionCell *)cell;
        proverbCell.nameLabel.text = proverb.text;
        BOOL selected = [selectedProverbs containsObject:proverb];
        proverbCell.backgroundColor = selected?[UIColor flatDarkOrangeColor]:[UIColor flatGreenColor];
        proverbCell.nameLabel.textColor = selected ? [UIColor flatDarkYellowColor]:[UIColor flatYellowColor];
        proverbCell.nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        proverbCell.nameLabel.numberOfLines = 0;
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

- (Proverb *) proverbAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(proverbs.count >= indexPath.row, @"Ошибка: индекс за пределами массива");
    return [proverbs objectAtIndex:indexPath.row];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    Proverb *proverb = [self proverbAtIndexPath:indexPath];
    if (!proverb)
        return;
    if ([selectedProverbs containsObject:proverb]) {
        [selectedProverbs removeObject:proverb];
    }
    else {
        if (!selectedProverbs)
            selectedProverbs = [NSMutableSet setWithCapacity:1];
        [selectedProverbs addObject:proverb];
    }
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
}
@end
