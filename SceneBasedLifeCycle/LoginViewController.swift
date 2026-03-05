//
//  LoginViewController.swift
//  SceneBasedLifeCycle
//
//  Created by Codex CLI.
//

import UIKit

final class LoginViewController: UIViewController {

    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "ログイン"
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()

    private let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "メールアドレス"
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.clearButtonMode = .whileEditing
        tf.borderStyle = .roundedRect
        tf.returnKeyType = .next
        tf.textContentType = .username
        return tf
    }()

    private let passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "パスワード"
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.returnKeyType = .done
        tf.textContentType = .password
        return tf
    }()

    private let toggleSecureButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("表示", for: .normal)
        return btn
    }()

    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("ログイン", for: .normal)
        btn.isEnabled = false
        btn.backgroundColor = .systemBlue
        btn.tintColor = .white
        btn.layer.cornerRadius = 8
        btn.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        return btn
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.hidesWhenStopped = true
        return ai
    }()

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .fill
        sv.spacing = 12
        return sv
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "ログイン"
        setupUI()
        bind()
    }

    // MARK: - Setup
    private func setupUI() {
        // Secure toggle as right view
        toggleSecureButton.addTarget(self, action: #selector(toggleSecure), for: .touchUpInside)
        let rightContainer = UIView(frame: CGRect(x: 0, y: 0, width: 56, height: 44))
        toggleSecureButton.frame = rightContainer.bounds
        rightContainer.addSubview(toggleSecureButton)
        passwordField.rightView = rightContainer
        passwordField.rightViewMode = .always

        // Fields actions
        emailField.delegate = self
        passwordField.delegate = self
        emailField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

        // Layout
        view.addSubview(stackView)
        [titleLabel, emailField, passwordField, loginButton].forEach { stackView.addArrangedSubview($0) }
        loginButton.addSubview(activityIndicator)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(tapLogin), for: .touchUpInside)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),

            emailField.heightAnchor.constraint(equalToConstant: 44),
            passwordField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func bind() {
        updateLoginButtonState()
    }

    // MARK: - Actions
    @objc private func toggleSecure() {
        passwordField.isSecureTextEntry.toggle()
        let title = passwordField.isSecureTextEntry ? "表示" : "非表示"
        toggleSecureButton.setTitle(title, for: .normal)
        // カーソル位置が末尾に飛ばないように再設定
        let text = passwordField.text
        passwordField.text = nil
        passwordField.text = text
    }

    @objc private func textDidChange() {
        updateLoginButtonState()
    }

    @objc private func tapLogin() {
        view.endEditing(true)
        setLoading(true)

        // 疑似ログイン（0.8秒ディレイで成功）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            self.setLoading(false)
            if self.isValid() {
                // 成功時: 設定画面へ
                let next = SettingsViewController()
                self.navigationController?.pushViewController(next, animated: true)
            } else {
                let alert = UIAlertController(title: "ログイン失敗", message: "メールアドレスまたはパスワードをご確認ください", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }

    // MARK: - Helpers
    private func updateLoginButtonState() {
        let enabled = isValid()
        loginButton.isEnabled = enabled
        loginButton.alpha = enabled ? 1.0 : 0.5
    }

    private func isValid() -> Bool {
        guard let email = emailField.text, let pass = passwordField.text else { return false }
        return !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && pass.count >= 6
    }

    private func setLoading(_ loading: Bool) {
        loginButton.isEnabled = !loading
        loading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            if loginButton.isEnabled { tapLogin() }
        }
        return true
    }
}

