import Foundation
import AVFoundation
import Accelerate

/// Real-time audio capture e processamento com análise de amplitude
class AudioManager: NSObject, ObservableObject {
    
    // MARK: - Published State
    
    @Published var isRecording: Bool = false
    @Published var amplitude: Float = 0.0  // 0.0 - 1.0
    @Published var isSpeaking: Bool = false
    
    // MARK: - Audio Engine
    
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private let audioSession = AVAudioSession.sharedInstance()
    
    // MARK: - Configuration
    
    private let sampleRate: Double = 44100.0
    private let bufferSize: AVAudioFrameCount = 1024
    private let speakingThreshold: Float = 0.02  // Threshold para detectar fala
    
    // MARK: - Callbacks
    
    var onAudioBuffer: ((AVAudioPCMBuffer) -> Void)?
    var onSpeechDetected: (() -> Void)?
    var onSilenceDetected: (() -> Void)?
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    // MARK: - Setup
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
            print("✅ Audio session configurado")
        } catch {
            print("❌ Erro ao configurar audio session: \(error)")
        }
    }
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        inputNode = audioEngine?.inputNode
        
        guard let inputNode = inputNode else {
            print("❌ Input node não disponível")
            return
        }
        
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        // Instalar tap para captura de áudio
        inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: inputFormat) { [weak self] buffer, time in
            self?.processAudioBuffer(buffer)
        }
        
        print("✅ Audio engine configurado - Sample Rate: \(inputFormat.sampleRate)Hz")
    }
    
    // MARK: - Public Control
    
    func startRecording() {
        guard !isRecording else { return }
        
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        guard status == .authorized else {
            print("⚠️ Permissão de microfone não concedida. Gravação abortada.")
            return
        }
        
        setupAudioEngine()
        
        guard let audioEngine = audioEngine else { return }
        
        do {
            audioEngine.prepare()
            try audioEngine.start()
            
            DispatchQueue.main.async {
                self.isRecording = true
            }
            
            print("▶️ Gravação de áudio iniciada")
        } catch {
            print("❌ Erro ao iniciar audio engine: \(error)")
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        inputNode?.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        
        DispatchQueue.main.async {
            self.isRecording = false
            self.isSpeaking = false
            self.amplitude = 0.0
        }
        
        print("⏹️ Gravação de áudio parada")
    }
    
    // MARK: - Audio Processing
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }
        
        let channelDataValue = channelData.pointee
        let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride).map { channelDataValue[$0] }
        
        // Calcular RMS (Root Mean Square) para amplitude
        let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        
        // Normalizar para 0.0 - 1.0
        let normalizedAmplitude = min(rms * 10.0, 1.0)
        
        // Detectar fala baseado em threshold
        let speaking = normalizedAmplitude > speakingThreshold
        
        DispatchQueue.main.async {
            self.amplitude = normalizedAmplitude
            
            if speaking != self.isSpeaking {
                self.isSpeaking = speaking
                
                if speaking {
                    self.onSpeechDetected?()
                } else {
                    self.onSilenceDetected?()
                }
            }
        }
        
        // Callback com buffer bruto para processamento adicional
        onAudioBuffer?(buffer)
    }
    
    // MARK: - Cleanup
    
    deinit {
        stopRecording()
        try? audioSession.setActive(false)
    }
}
