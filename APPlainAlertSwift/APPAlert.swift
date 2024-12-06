//
//  APPAlert.swift
//  APPlainAlertSwift
//
//  Created by Parti Albert on 2024. 12. 05..
//
import UIKit

protocol APPlainAlertDelegate: AnyObject {
    func progressStatus(_ floatCount: Float)
    func closeButtonAction()
}

enum APPlainAlertType {
    case error, success, info, progress, panic, unknown
}

enum APPlainAlertPosition {
    case top, bottom
}

class APPlainAlert: UIViewController {
    weak var delegate: APPlainAlertDelegate?

    // Figyelmeztetés tulajdonságok
    var titleFont: UIFont = UIFont.systemFont(ofSize: 15)
    var subTitleFont: UIFont = UIFont.systemFont(ofSize: 12)
    var progressTitleFont: UIFont = UIFont.boldSystemFont(ofSize: 14)

    var titleString: String?
    var subtitleString: String?
    var progressSubtitleString: String?
    var type: APPlainAlertType = .info

    var messageColor: UIColor = .white
    var iconColor: UIColor = .blue
    var hiddenDelay: Float = 4.0
    var blurBackground: Bool = false
    var shouldShowCloseIcon: Bool = true
    var closeButtonColor: UIColor = .red // Bezáró gomb színe alapértelmezetten piros

    // Új tulajdonságok a cím és alszöveg színének testreszabásához
    var titleColor: UIColor = .black // Alapértelmezett címsor színe
    var subtitleColor: UIColor = .darkGray // Alapértelmezett alszöveg színe

    var titleLabel: UILabel?
    var subtitleLabel: UILabel?
    var progressBar: UIProgressView?
    var iconImageView: UIImageView?

    // Akció a figyelmeztetésre történő kattintáskor
    var action: (() -> Void)?

    static var currentAlertArray: [APPlainAlert] = []
    static var alertPosition: APPlainAlertPosition = .bottom

    // Inicializálás
    init(title: String, message: String, type: APPlainAlertType) {
        super.init(nibName: nil, bundle: nil)
        self.titleString = title
        self.subtitleString = message
        self.type = type
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Figyelmeztetés megjelenítése
    func show() {
        DispatchQueue.main.async {
            self.setupView()
        }
    }

    func setupView() {
        guard let window = UIApplication.shared.windows.first else { return }

        let alertCount = CGFloat(APPlainAlert.currentAlertArray.count)
        let startYPosition: CGFloat = (APPlainAlert.alertPosition == .top) ? -150 - (alertCount * 130) : window.bounds.height + (alertCount * 130)

        self.view.frame = CGRect(x: 10, y: startYPosition, width: window.bounds.width - 20, height: 120)
        self.view.backgroundColor = self.messageColor
        self.view.layer.cornerRadius = 10
        self.view.clipsToBounds = true

        if blurBackground {
            let blurEffect = UIBlurEffect(style: .light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = self.view.bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(blurView)
        }

        // Ikon beállítása
        iconImageView = UIImageView(frame: CGRect(x: 15, y: (self.view.frame.height - 50) / 2, width: 50, height: 50))
        iconImageView?.contentMode = .scaleAspectFit
        iconImageView?.tintColor = iconColor

        switch type {
        case .success:
            iconImageView?.image = UIImage(systemName: "checkmark.circle.fill")
        case .error:
            iconImageView?.image = UIImage(systemName: "xmark.octagon.fill")
        case .info:
            iconImageView?.image = UIImage(systemName: "info.circle.fill")
        case .progress:
            iconImageView?.image = UIImage(systemName: "arrow.down.circle.fill")
        case .panic:
            iconImageView?.image = UIImage(systemName: "exclamationmark.triangle.fill")
        default:
            iconImageView?.image = UIImage(systemName: "questionmark.circle.fill")
        }
        
        if let iconImageView = iconImageView {
            self.view.addSubview(iconImageView)
        }

        // Címke beállítása
        titleLabel = UILabel(frame: CGRect(x: 75, y: 10, width: self.view.frame.width - 90, height: 20))
        titleLabel?.text = titleString
        titleLabel?.font = titleFont
        titleLabel?.textColor = titleColor // Beállított címsor szín
        self.view.addSubview(titleLabel!)

        // Alszöveg beállítása
        subtitleLabel = UILabel(frame: CGRect(x: 75, y: 35, width: self.view.frame.width - 90, height: 20))
        subtitleLabel?.text = subtitleString
        subtitleLabel?.font = subTitleFont
        subtitleLabel?.textColor = subtitleColor // Beállított alszöveg szín
        self.view.addSubview(subtitleLabel!)

        // Bezáró gomb beállítása (ha szükséges)
        if shouldShowCloseIcon {
            let closeButton = UIButton(type: .system)
            closeButton.frame = CGRect(x: self.view.frame.width - 35, y: 5, width: 30, height: 30)

            // Szép bezáró kép beállítása az "xmark.circle.fill" rendszer ikonnal
            let closeImage = UIImage(systemName: "xmark.circle.fill")
            closeButton.setImage(closeImage, for: .normal)

            // Bezáró gomb színének testreszabása
            closeButton.tintColor = closeButtonColor

            closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
            self.view.addSubview(closeButton)
        }

        // Progress bar beállítása (ha szükséges)
        if type == .progress {
            progressBar = UIProgressView(progressViewStyle: .default)
            progressBar?.frame = CGRect(x: 75, y: 70, width: self.view.frame.width - 90, height: 10)
            progressBar?.progressTintColor = .blue
            progressBar?.trackTintColor = .lightGray
            self.view.addSubview(progressBar!)
        }

        // Tap gesture hozzáadása a figyelmeztetéshez
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(alertTapped))
        self.view.addGestureRecognizer(tapGesture)

        window.addSubview(self.view)

        UIView.animate(withDuration: 0.3) {
            let endYPosition: CGFloat = (APPlainAlert.alertPosition == .top) ? 50 + (alertCount * 130) : window.bounds.height - 150 - (alertCount * 130)
            self.view.frame.origin.y = endYPosition
        }

        APPlainAlert.currentAlertArray.append(self)
        if type != .progress {
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(hiddenDelay)) {
                self.hide()
            }
        }
    }

    @objc func closeButtonTapped() {
        hide()
        delegate?.closeButtonAction()
    }

    @objc func alertTapped() {
        if let action = action {
            action()
        }
    }

    func hide() {
        UIView.animate(withDuration: 0.3, animations: {
            let endYPosition: CGFloat = (APPlainAlert.alertPosition == .top) ? -150 : UIScreen.main.bounds.height
            self.view.frame.origin.y = endYPosition
        }) { _ in
            self.view.removeFromSuperview()
            if let index = APPlainAlert.currentAlertArray.firstIndex(of: self) {
                APPlainAlert.currentAlertArray.remove(at: index)
                self.updateAlertPositions()
            }
        }
    }

    func updateAlertPositions() {
        for (index, alert) in APPlainAlert.currentAlertArray.enumerated() {
            UIView.animate(withDuration: 0.3) {
                let endYPosition: CGFloat = (APPlainAlert.alertPosition == .top) ? 50 + (CGFloat(index) * 130) : UIScreen.main.bounds.height - 150 - (CGFloat(index) * 130)
                alert.view.frame.origin.y = endYPosition
            }
        }
    }

    func progressView(progress: Float, status: String) {
        progressBar?.progress = progress
        progressSubtitleString = status
        if progress == 1.0 {
            hidedelayprogress()
        }
    }

    func hidedelayprogress() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.hide()
        }
    }

    static func updateAlertPosition(_ position: APPlainAlertPosition) {
        alertPosition = position
    }

    static func hideAll() {
        for alert in currentAlertArray {
            alert.hide()
        }
        currentAlertArray.removeAll()
    }
}
