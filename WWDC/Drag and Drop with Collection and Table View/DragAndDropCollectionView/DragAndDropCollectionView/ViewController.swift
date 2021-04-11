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
}
