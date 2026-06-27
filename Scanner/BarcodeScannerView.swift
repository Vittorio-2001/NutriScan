//
//  BarcodeScannerView.swift
//  NutriScan
//
//  Created by Vittorio Monfrecola on 16/11/25.
//


import SwiftUI
import AVFoundation

struct BarcodeScannerView: UIViewControllerRepresentable {

    @Binding var isScanning: Bool
    let onCodeScanned: (String) -> Void

    func makeUIViewController(context: Context) -> ScannerViewController {
        let vc = ScannerViewController()
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        uiViewController.isScanning = isScanning
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, ScannerViewControllerDelegate {
        let parent: BarcodeScannerView
        init(parent: BarcodeScannerView) { self.parent = parent }

        func scannerViewController(_ controller: ScannerViewController, didCaptureCode code: String) {
            parent.onCodeScanned(code)
        }
    }
}

// MARK: - Delegate

protocol ScannerViewControllerDelegate: AnyObject {
    func scannerViewController(_ controller: ScannerViewController, didCaptureCode code: String)
}

// MARK: - ScannerViewController

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    weak var delegate: ScannerViewControllerDelegate?
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    var isScanning: Bool = true {
        didSet {
            if isScanning {
                DispatchQueue.global(qos: .userInitiated).async {
                    self.captureSession?.startRunning()
                }
            } else {
                captureSession?.stopRunning()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraPermission()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }

    // MARK: - Permission check

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted { self?.setupCamera() }
                    else       { self?.showPermissionDeniedUI() }
                }
            }
        case .denied, .restricted:
            showPermissionDeniedUI()
        @unknown default:
            showPermissionDeniedUI()
        }
    }

    // MARK: - Permission denied UI

    private func showPermissionDeniedUI() {
        view.backgroundColor = .black

        let icon = UIImageView(image: UIImage(systemName: "camera.slash.fill"))
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = "Camera access required"
        title.textColor = .white
        title.font = .boldSystemFont(ofSize: 18)
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false

        let sub = UILabel()
        sub.text = "Enable camera access in Settings\nto scan barcodes."
        sub.textColor = UIColor.white.withAlphaComponent(0.7)
        sub.font = .systemFont(ofSize: 14)
        sub.textAlignment = .center
        sub.numberOfLines = 0
        sub.translatesAutoresizingMaskIntoConstraints = false

        let btn = UIButton(type: .system)
        btn.setTitle("Open Settings", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 22
        btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 24)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(openSettings), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [icon, title, sub, btn])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 60),
            icon.heightAnchor.constraint(equalToConstant: 60),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32)
        ])
    }

    @objc private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Camera setup

    private func setupCamera() {
        let session = AVCaptureSession()

        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let videoInput  = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoInput) else { return }

        session.addInput(videoInput)

        let metadataOutput = AVCaptureMetadataOutput()
        guard session.canAddOutput(metadataOutput) else { return }
        session.addOutput(metadataOutput)

        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.ean13, .ean8, .upce, .code128, .qr]

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.layer.bounds
        view.layer.insertSublayer(preview, at: 0)

        captureSession = session
        previewLayer   = preview

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }

    // MARK: - Metadata delegate

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {

        guard isScanning,
              let obj  = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = obj.stringValue else { return }

        isScanning = false
        delegate?.scannerViewController(self, didCaptureCode: code)
    }
}
