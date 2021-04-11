import UIKit

class ViewController: UIViewController {
    enum Section {
        case main
    }
    
    var collectionView: UICollectionView!
    var diffableDataSource: UICollectionViewDiffableDataSource<Section, String>!
    var dataToPresent: [String] = ["Hello World!", "Swift is Good!", "iOS Lover!"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
        configureSnapshot()
    }
}

//MARK: - CollectionView -
extension ViewController {
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: configureCollectionViewLayout())
        view.addSubview(collectionView)
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dragInteractionEnabled = true
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.register(MyCell.self, forCellWithReuseIdentifier: MyCell.reuseIdentifier)
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

//MARK: - Diffable DataSource -
extension ViewController {
    private func configureDataSource() {
        diffableDataSource = UICollectionViewDiffableDataSource<Section, String>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, string) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCell.reuseIdentifier, for: indexPath) as? MyCell else {
                return nil
            }
            cell.configure(with: string)
            return cell
        })
    }
    
    private func configureSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.main])
        snapshot.appendItems(dataToPresent)
        
        diffableDataSource.apply(snapshot)
    }
    
    private func reorderDataSource(string: String, source: IndexPath, destination: IndexPath) {
        var snapshot = diffableDataSource.snapshot()
        
        guard let lastItem = diffableDataSource.itemIdentifier(for: destination) else {
            return
        }
        
        if source.row > destination.row {
            snapshot.moveItem(string, beforeItem: lastItem)
        } else {
            snapshot.moveItem(string, afterItem: lastItem)
        }
        
        diffableDataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension ViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let item = diffableDataSource.itemIdentifier(for: indexPath) else {
            return []
        }
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
}

extension ViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        guard session.items.count == 1 else {
            return UICollectionViewDropProposal(operation: .cancel)
        }
        
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let dragItem = coordinator.items.first?.dragItem,
              let sourceIndexPath = coordinator.items.first?.sourceIndexPath else {
            return
        }
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        dragItem.itemProvider.loadObject(ofClass: String.self, completionHandler: { [weak self] (string, error) in
            guard let self = self,
                  error == nil,
                  let string = string else {
                return
            }
            DispatchQueue.main.async {
                self.reorderDataSource(string: string, source: sourceIndexPath, destination: destinationIndexPath)
            }
        })
        coordinator.drop(dragItem, toItemAt: destinationIndexPath)
    }
}
