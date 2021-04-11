import UIKit

class MyCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: MyCell.self)
    private let padding: CGFloat = 8.0
    
    let label: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        confgiureLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func confgiureLabel() {
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: padding),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with string: String) {
        label.text = string
    }
}
