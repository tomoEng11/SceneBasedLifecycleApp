//
//  ViewController.swift
//  SceneBasedLifeCycle
//
//  Created by 井本　智博 on 2025/08/14.
//

import UIKit

final class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan


    }


}

final class SettingsViewController: UIViewController {
    
    private let textView: PlaceholderTextView = PlaceholderTextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setUpUI() {
        textView.delegate = self
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .red
        textView.textColor = .white
        textView.isScrollEnabled = true
        view.backgroundColor = .yellow
        textView.text = "Following on from our last post, and on the other side of US politics, Democrats in Congress say they're ready to act if Trump and Putin's meeting tomorrow yields no progress in ending the war in Ukraine.Jeanne Shaheen, the top Democrat on the Senate Foreign Relations Committee, tells CNN that Trump's handling of Russia has been an  and that Putin has been  since he took office.President Trump has set one red line after another and Vladimir Putin has continued to cross them, she says.Shaheen continues, saying Zelensky should be at the table for discussions about the war and that the US should be providing more support and weapons to Ukraine.If significant steps aren't taken in Alaska tomorrow, Congress will submit a Russia sanctions bill, she tells the broadcaster: If the president can't get any progress, we intend to act."

        NSLayoutConstraint.activate([
            textView.heightAnchor.constraint(equalToConstant: 100),
            textView.widthAnchor.constraint(equalToConstant: 300),
            textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
}

extension SettingsViewController:  UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
    }
}


@IBDesignable
final class PlaceholderTextView: UITextView {

    // MARK: - Public

    /// プレースホルダー文字列
    @IBInspectable var placeholder: String = "" {
        didSet { placeholderLabel.text = placeholder }
    }

    /// プレースホルダー色
    @IBInspectable var placeholderColor: UIColor = .placeholderText {
        didSet { placeholderLabel.textColor = placeholderColor }
    }

    /// プレースホルダーの左右マージン（本文のlineFragmentPaddingとずれないように）
    @IBInspectable var placeholderHorizontalInset: CGFloat = 0 {
        didSet { updatePlaceholderConstraints() }
    }

    // MARK: - Private

    private let placeholderLabel = UILabel()
    private var placeholderTopConstraint: NSLayoutConstraint?
    private var placeholderLeadingConstraint: NSLayoutConstraint?
    private var placeholderTrailingConstraint: NSLayoutConstraint?

    // MARK: - Init

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        // 基本設定
        isScrollEnabled = true

        // Placeholder label
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.backgroundColor = .clear
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.isAccessibilityElement = false
        addSubview(placeholderLabel)

        // 初期フォント/整列はTextViewに追従
        placeholderLabel.font = self.font ?? UIFont.preferredFont(forTextStyle: .body)
        placeholderLabel.textAlignment = self.textAlignment

        // 制約
        updatePlaceholderConstraints()

        // 変更監視
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChangeNotification),
            name: UITextView.textDidChangeNotification,
            object: self
        )
        // Dynamic Type対応
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentSizeCategoryDidChange),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )

        updatePlaceholderVisibility()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Layout

    override var text: String! {
        didSet { updatePlaceholderVisibility() }
    }

    override var attributedText: NSAttributedString! {
        didSet {
            // フォント/整列が変わる可能性がある
            placeholderLabel.font = self.font ?? placeholderLabel.font
            placeholderLabel.textAlignment = self.textAlignment
            updatePlaceholderVisibility()
        }
    }

    override var font: UIFont? {
        didSet { placeholderLabel.font = font }
    }

    override var textAlignment: NSTextAlignment {
        didSet { placeholderLabel.textAlignment = textAlignment }
    }

    override var textContainerInset: UIEdgeInsets {
        didSet { updatePlaceholderConstraints() }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // サイズ変化で折り返し再計算
        placeholderLabel.preferredMaxLayoutWidth = textContainer.size.width - textContainer.lineFragmentPadding * 2
    }

    // MARK: - Actions

    @objc private func textDidChangeNotification() {
        updatePlaceholderVisibility()
    }

    @objc private func contentSizeCategoryDidChange() {
        if let font = self.font {
            placeholderLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        }
    }

    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !text.isEmpty
        // VoiceOver: 文字が空ならplaceholderをヒントとして読ませる
        accessibilityHint = text.isEmpty ? placeholder : nil
    }

//    private func updatePlaceholderConstraints() {
//        // 既存制約を外して作り直し
//        if let c = placeholderTopConstraint { removeConstraint(c) }
//        if let c = placeholderLeadingConstraint { removeConstraint(c) }
//        if let c = placeholderTrailingConstraint { removeConstraint(c) }
//
//        // UITextViewの内側余白に合わせる
//        let top = textContainerInset.top
//        let left = textContainerInset.left + textContainer.lineFragmentPadding + placeholderHorizontalInset
//        let right = -(textContainerInset.right + textContainer.lineFragmentPadding + placeholderHorizontalInset)
//
//        placeholderTopConstraint = placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: top)
//        placeholderLeadingConstraint = placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: left)
//        placeholderTrailingConstraint = placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: right)
//
//        NSLayoutConstraint.activate([
//            placeholderTopConstraint!,
//            placeholderLeadingConstraint!,
//            placeholderTrailingConstraint!
//        ])
//    }
    
    
    private func updatePlaceholderConstraints() {
        // 既存の制約をまとめて外す
        var toDeactivate: [NSLayoutConstraint] = []
        if let c = placeholderTopConstraint      { toDeactivate.append(c) }
        if let c = placeholderLeadingConstraint  { toDeactivate.append(c) }
        if let c = placeholderTrailingConstraint { toDeactivate.append(c) }
        NSLayoutConstraint.deactivate(toDeactivate)

        // UITextView の“内側”に合わせて余白計算
        let top    = textContainerInset.top
        let left   = textContainerInset.left  + textContainer.lineFragmentPadding + placeholderHorizontalInset
        let right  = -(textContainerInset.right + textContainer.lineFragmentPadding + placeholderHorizontalInset)
        let bottom = -(textContainerInset.bottom)

        // 上・左・右は固定。下は「≤」で逃がす（これが contentSize の曖昧さ防止に効く）
        placeholderTopConstraint     = placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: top)
        placeholderLeadingConstraint = placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: left)
        placeholderTrailingConstraint = placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: right)

        let bottomLE = placeholderLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: bottom)
        bottomLE.priority = UILayoutPriority(750) // = .defaultHigh

        NSLayoutConstraint.activate([
            placeholderTopConstraint!,
            placeholderLeadingConstraint!,
            placeholderTrailingConstraint!,
            bottomLE
        ])
    }
}
