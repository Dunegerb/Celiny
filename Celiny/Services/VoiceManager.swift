import Foundation
import AVFoundation

/// Voice synthesis com controle de prosódia e emoção
class VoiceManager: NSObject, ObservableObject {
    
    // MARK: - Published State
    
    @Published var isSpeaking: Bool = false
    @Published var currentUtterance: String = ""
    
    // MARK: - Speech Synthesizer
    
    private let synthesizer = AVSpeechSynthesizer()
    
    // MARK: - Configuration
    
    private var currentVoice: AVSpeechSynthesisVoice?
    private var defaultRate: Float = AVSpeechUtteranceDefaultSpeechRate
    private var defaultPitch: Float = 1.0
    private var defaultVolume: Float = 1.0
    
    // MARK: - Callbacks
    
    var onSpeechStarted: (() -> Void)?
    var onSpeechFinished: (() -> Void)?
    var onSpeechPaused: (() -> Void)?
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        synthesizer.delegate = self
        setupVoice()
    }
    
    // MARK: - Setup
    
    private func setupVoice() {
        // Prefer Brazilian Portuguese voice
        let voices = AVSpeechSynthesisVoice.speechVoices()
        
        // Procurar voz pt-BR feminina primeiro
        currentVoice = voices.first { voice in
            voice.language == "pt-BR" && voice.gender == .female
        }
        
        // Fallback para qualquer voz pt-BR
        if currentVoice == nil {
            currentVoice = voices.first { $0.language == "pt-BR" }
        }
        
        // Fallback final para inglês
        if currentVoice == nil {
            currentVoice = AVSpeechSynthesisVoice(language: "en-US")
        }
        
        if let voice = currentVoice {
            print("✅ Voz configurada: \(voice.name) (\(voice.language))")
        }
    }
    
    // MARK: - Public API
    
    /// Falar texto com configurações padrão
    func speak(_ text: String) {
        speak(text, rate: defaultRate, pitch: defaultPitch, volume: defaultVolume)
    }
    
    /// Falar texto com emoção específica
    func speak(_ text: String, emotion: EmotionType) {
        let config = emotionConfiguration(for: emotion)
        speak(text, rate: config.rate, pitch: config.pitch, volume: config.volume)
    }
    
    /// Falar texto com controle completo de prosódia
    func speak(
        _ text: String,
        rate: Float = AVSpeechUtteranceDefaultSpeechRate,
        pitch: Float = 1.0,
        volume: Float = 1.0
    ) {
        guard !text.isEmpty else { return }
        
        // Parar fala anterior se houver
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = currentVoice
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.volume = volume
        
        // Pre-utterance delay
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.1
        
        DispatchQueue.main.async {
            self.currentUtterance = text
        }
        
        synthesizer.speak(utterance)
        
        print("🗣️ Falando: \"\(text)\"")
    }
    
    /// Pausar fala atual
    func pause() {
        guard synthesizer.isSpeaking else { return }
        synthesizer.pauseSpeaking(at: .word)
    }
    
    /// Continuar fala pausada
    func resume() {
        guard synthesizer.isPaused else { return }
        synthesizer.continueSpeaking()
    }
    
    /// Parar fala imediatamente
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    // MARK: - Emotion Configurations
    
    private struct VoiceConfiguration {
        let rate: Float
        let pitch: Float
        let volume: Float
    }
    
    private func emotionConfiguration(for emotion: EmotionType) -> VoiceConfiguration {
        switch emotion {
        case .neutral:
            return VoiceConfiguration(
                rate: AVSpeechUtteranceDefaultSpeechRate,
                pitch: 1.0,
                volume: 0.8
            )
            
        case .happy:
            return VoiceConfiguration(
                rate: AVSpeechUtteranceDefaultSpeechRate * 1.1,  // Mais rápido
                pitch: 1.2,  // Mais agudo
                volume: 0.9
            )
            
        case .sad:
            return VoiceConfiguration(
                rate: AVSpeechUtteranceDefaultSpeechRate * 0.8,  // Mais devagar
                pitch: 0.8,  // Mais grave
                volume: 0.7
            )
            
        case .excited:
            return VoiceConfiguration(
                rate: AVSpeechUtteranceDefaultSpeechRate * 1.2,
                pitch: 1.3,
                volume: 1.0
            )
            
        case .calm:
            return VoiceConfiguration(
                rate: AVSpeechUtteranceDefaultSpeechRate * 0.9,
                pitch: 0.95,
                volume: 0.75
            )
            
        case .surprised:
            return VoiceConfiguration(
                rate: AVSpeechUtteranceDefaultSpeechRate * 1.15,
                pitch: 1.25,
                volume: 0.95
            )
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension VoiceManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = true
            self.onSpeechStarted?()
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.currentUtterance = ""
            self.onSpeechFinished?()
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.onSpeechPaused?()
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.currentUtterance = ""
        }
    }
}

// MARK: - Supporting Types

enum EmotionType {
    case neutral
    case happy
    case sad
    case excited
    case calm
    case surprised
}
