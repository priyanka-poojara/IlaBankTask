//
//  CarouselList+Delegate.swift
//  IlaBankTask
//
//  Created by Neosoft on 29/08/24.
//

import UIKit

extension CarouselListViewController: UICollectionViewDelegate {
    
    func createGroupLayout() -> UICollectionViewLayout {
        return carouselListLayout()
    }
    
    private func carouselListLayout() -> UICollectionViewCompositionalLayout {
        
        return UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            
            switch sectionIndex {
            case 0: return self.createCarouselSection()
            case 1: return self.createSearchSection()
            case 2: return self.createCarouselListSection()
            default: return nil
            }
        }
        
    }
    
    private func createCarouselSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(250))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        section.boundarySupplementaryItems = [createFooter()]
        section.interGroupSpacing = 0
        
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, point, env in
            guard let self = self else { return }
            
            guard let lastVisibleItem = visibleItems.last else { return }
            
            let currentIndexPath = lastVisibleItem.indexPath
            print("LAST VISIBLE ITEM",currentIndexPath)
            if viewModel?.viewState.currentIndex != currentIndexPath.row {
                // Update the page control in the footer view
                if let financialServices = viewModel?.viewState.financialServices,
                   let collectionView = self.clvCarouselList,
                   let footerView = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: 0)) as? PageControlView {
                    
                    let totalPages = financialServices.count
                    footerView.pageControlViewDidUpdatePage(to: currentIndexPath.row, totalPageCount: totalPages)
                    
                    // Reload data only when the index changes
                    viewModel?.reloadServices(currentIndex: currentIndexPath.row)
                    title = viewModel?.viewState.currentServiceTitle
                    collectionView.reloadSections(IndexSet(integer: 2))
                    collectionView.reloadSections(IndexSet(integer: 1))
                }
            }
        }
//        handleVisibleItemsInvalidation
        
        return section
    }
    
    private func createCarouselListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(130))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
//        section.boundarySupplementaryItems = [createHeader()]

        return section
    }
    
    private func createSearchSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Create an empty group since we don't want any items in the section
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(1))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        // Create the section with the empty group
        let section = NSCollectionLayoutSection(group: group)
        
        // Add the header to the section
        section.boundarySupplementaryItems = [createHeader()]
        
        return section
    }

    private func createFooter() -> NSCollectionLayoutBoundarySupplementaryItem {
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(20))
        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
    }
    
    private func createHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(70))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        header.pinToVisibleBounds = true
        header.zIndex = 999
        return header
    }
    
    private func handleVisibleItemsInvalidation(visibleItems: [NSCollectionLayoutVisibleItem], point: CGPoint, environment: NSCollectionLayoutEnvironment) {
        guard let currentIndexPath = visibleItems.last?.indexPath,
              viewModel?.viewState.currentIndex != currentIndexPath.row else { return }
        
        // Update the page control in the footer view
        if let financialServices = viewModel?.viewState.financialServices,
           let collectionView = self.clvCarouselList,
           let footerView = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: 0)) as? PageControlView {
            
            let totalPages = financialServices.count
            footerView.pageControlViewDidUpdatePage(to: currentIndexPath.row, totalPageCount: totalPages)
            
            // Reload data only when the index changes
            viewModel?.reloadServices(currentIndex: currentIndexPath.row)
//            print(currentIndexPath.row)
            print("Create Carousel called, \(currentIndexPath.row)")
            title = viewModel?.viewState.currentServiceTitle
            collectionView.reloadSections(IndexSet(integer: 2))
        }
    }
    
}

extension CarouselListViewController: SearchViewDelegate {
    
    func didUpdateSearchText(_ searchText: String) {
        viewModel?.seachServices(searchText: searchText)
        
        clvCarouselList.reloadSections(IndexSet(integer: 2))

    }
    
}
