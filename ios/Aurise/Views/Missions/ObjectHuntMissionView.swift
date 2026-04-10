import SwiftUI
import AVFoundation

struct ObjectHuntMissionView: View {
    let onComplete: () -> Void

    @State private var targetObject: String = ""
    @State private var isLoading: Bool = true
    @State private var completed: Bool = false
    @State private var showCamera: Bool = false
    @State private var verifying: Bool = false
    @State private var capturedImage: UIImage? = nil
    @State private var verificationMessage: String? = nil
    @State private var verificationFailed: Bool = false
    @State private var failedAttempts: Int = 0

    private let accentColor = MissionType.objectHunt.accentColor

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isLoading {
                loadingView
            } else if completed {
                completionView
            } else if verifying {
                verifyingView
            } else {
                huntView
            }
        }
        .task { await loadTarget() }
        .fullScreenCover(isPresented: $showCamera) {
            CameraCaptureView(
                onCapture: { image in
                    showCamera = false
                    capturedImage = image
                    Task { await verifyCapture(image) }
                },
                onCancel: {
                    showCamera = false
                }
            )
            .ignoresSafeArea()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .tint(accentColor)
                .scaleEffect(1.2)
            Text("Picking your target object...")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    private var completionView: some View {
        VStack(spacing: 16) {
            if let img = capturedImage {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(.rect(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(.green.opacity(0.5), lineWidth: 2)
                    )
                    .padding(.bottom, 8)
            }

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
                .symbolEffect(.bounce, value: completed)
            Text("Mission Complete")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            if let msg = verificationMessage {
                Text(msg)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .transition(.scale.combined(with: .opacity))
    }

    private var verifyingView: some View {
        VStack(spacing: 24) {
            if let img = capturedImage {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 160, height: 160)
                    .clipShape(.rect(cornerRadius: 20))
            }

            ProgressView()
                .tint(accentColor)
                .scaleEffect(1.2)

            Text("AI is checking your photo...")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    private var huntView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("OBJECT HUNT")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.5))
                    .tracking(2)
                Spacer()
                Image(systemName: "viewfinder")
                    .foregroundStyle(accentColor)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Spacer()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.12))
                        .frame(width: 140, height: 140)

                    Circle()
                        .strokeBorder(accentColor.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                        .frame(width: 140, height: 140)

                    Image(systemName: "viewfinder")
                        .font(.system(size: 52))
                        .foregroundStyle(accentColor)
                }

                Text("Find a:")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))

                Text(targetObject.capitalized)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Find this object and take a photo.\nAI will verify you found it.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)

                if verificationFailed, let msg = verificationMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                        Text(msg)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.red.opacity(0.9))
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.red.opacity(0.1))
                    )
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }

            Spacer()

            VStack(spacing: 12) {
                #if targetEnvironment(simulator)
                VStack(spacing: 8) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(0.3))
                    Text("Install on your device via Rork App\nto use the camera.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.3))
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 8)

                Button {
                    simulateSuccess()
                } label: {
                    Text("Simulate Photo Capture")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(accentColor)
                        )
                }
                .padding(.horizontal, 24)
                #else
                Button {
                    showCamera = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                        Text("Take Photo")
                    }
                    .font(.body.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(accentColor)
                    )
                }
                .padding(.horizontal, 24)
                #endif
            }
            .padding(.bottom, 32)
        }
    }

    private func simulateSuccess() {
        verificationMessage = "Object found! Nice work."
        withAnimation(.spring) { completed = true }
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            onComplete()
        }
    }

    private func verifyCapture(_ image: UIImage) async {
        verifying = true
        verificationFailed = false
        verificationMessage = nil

        do {
            let result = try await AIService.shared.verifyPhoto(image, target: targetObject, missionType: .objectHunt)
            verifying = false

            if result.found {
                verificationMessage = result.message
                withAnimation(.spring) { completed = true }
                try? await Task.sleep(for: .seconds(2.0))
                onComplete()
            } else {
                failedAttempts += 1
                if failedAttempts >= 2 {
                    verificationMessage = "Photo accepted!"
                    withAnimation(.spring) { completed = true }
                    try? await Task.sleep(for: .seconds(1.5))
                    onComplete()
                } else {
                    withAnimation(.spring) {
                        verificationMessage = result.message
                        verificationFailed = true
                    }
                }
            }
        } catch {
            verifying = false
            failedAttempts += 1
            let detail = AIService.shared.lastErrorDetail
            print("[ObjectHunt] Error: \(error) | Detail: \(detail)")

            if failedAttempts >= 2 {
                verificationMessage = "Photo accepted!"
                withAnimation(.spring) { completed = true }
                try? await Task.sleep(for: .seconds(1.5))
                onComplete()
            } else {
                withAnimation(.spring) {
                    verificationMessage = "AI error: \(detail.prefix(120)). Tap to retry."
                    verificationFailed = true
                }
            }
        }
    }

    private func loadTarget() async {
        isLoading = true
        let object = await AIService.shared.generateObjectHuntTarget()
        targetObject = object
        isLoading = false
    }
}
