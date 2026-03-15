import AVFoundation
import Foundation

@Observable
@MainActor
class AudioRecordingService {
    var isRecording = false
    var audioLevel: Float = 0.0
    var recordingDuration: TimeInterval = 0
    var hasPermission = false

    private var audioRecorder: AVAudioRecorder?
    private var levelTimer: Timer?
    private var startTime: Date?
    private var durationTimer: Timer?

    func requestPermission() async {
        if #available(iOS 17.0, *) {
            hasPermission = await AVAudioApplication.requestRecordPermission()
        } else {
            hasPermission = await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    func startRecording() {
        guard hasPermission else { return }

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            return
        }

        let url = URL.temporaryDirectory.appendingPathComponent("tilawa_recording_\(UUID().uuidString).m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            isRecording = true
            startTime = Date()

            levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.updateAudioLevel()
                }
            }
            durationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.updateDuration()
                }
            }
        } catch {
            isRecording = false
        }
    }

    func stopRecording() -> URL? {
        let url = audioRecorder?.url
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        audioLevel = 0
        recordingDuration = 0
        levelTimer?.invalidate()
        levelTimer = nil
        durationTimer?.invalidate()
        durationTimer = nil
        startTime = nil
        return url
    }

    private func updateAudioLevel() {
        audioRecorder?.updateMeters()
        let level = audioRecorder?.averagePower(forChannel: 0) ?? -160
        let normalized = max(0, min(1, (level + 50) / 50))
        audioLevel = normalized
    }

    private func updateDuration() {
        guard let startTime else { return }
        recordingDuration = Date().timeIntervalSince(startTime)
    }
}
