# Celiny - iOS App

![iOS Build](https://github.com/Dunegerb/Celiny/actions/workflows/build-ios.yml/badge.svg)

Um ser minimalista que acompanha, imita, reage e evolui — local, privado e vivo.

## 🎯 Filosofia de Design

Baseado em neurociência e cognição incorporada seguindo princípios rigorosos de UX.

## 📱 Como Obter o App

### 🚀 Opção 1: Build Automático via GitHub Actions (SEM MAC!)

**Recomendado se você não tem Mac!**

1. Vá para [GitHub Actions](https://github.com/Dunegerb/Celiny/actions)
2. Clique em "Build iOS App" → "Run workflow"
3. Aguarde ~5-10 minutos
4. Baixe o `.ipa` dos Artifacts
5. Instale com **Sideloadly** no seu iPhone

📖 **Guia completo**: Veja [SIDELOADLY_GUIDE.md](SIDELOADLY_GUIDE.md)

### 💻 Opção 2: Compilar Manualmente no Xcode (COM MAC)

> **Importante**: Este é um projeto iOS nativo e requer **macOS com Xcode instalado**.

### Passo 1: Clone o repositório
```bash
git clone https://github.com/Dunegerb/Celiny.git
cd Celiny
```

### Passo 2: Abra no Xcode
```bash
open Celiny.xcodeproj
```

### Passo 3: Configure o projeto no Xcode
1. Selecione o projeto raiz "Celiny" no navegador
2. Em "Signing & Capabilities", selecione seu Team (Apple Developer Account)
3. Verifique que Bundle Identifier está como `com.celiny.app`
4. Certifique-se que as Capabilities estão habilitadas:
   - Camera Usage
   - Microphone Usage
   - User Notifications

### Passo 4: Compile e rode
- Simulador: Selecione iPhone 14 Pro ou superior → Run (⌘R)
- Dispositivo real: Conecte seu iPhone → Selecione o dispositivo → Run

### Passo 5: Gerar .ipa para instalação
```bash
# Via Xcode:
1. Product → Archive
2. Window → Organizer → Archives
3. Distribute App → Development / Ad Hoc
4. Export .ipa file

# Via linha de comando (macOS):
xcodebuild -scheme Celiny -archivePath ./build/Celiny.xcarchive archive
xcodebuild -exportArchive -archivePath ./build/Celiny.xcarchive -exportPath ./build -exportOptionsPlist ExportOptions.plist
```

## 🧱 Estrutura do Projeto

```
Celiny/
├── Celiny/
│   ├── App/
│   │   └── CelinyApp.swift              # Entry point
│   ├── DesignSystem/
│   │   ├── DesignTokens.swift           # Colors, spacing, typography
│   │   ├── HapticsEngine.swift          # Textured haptic feedback
│   │   └── AnimationSystem.swift        # Spring physics animations
│   ├── Components/
│   │   ├── Face/
│   │   │   ├── FaceView.swift           # Minimalist animated face
│   │   │   └── FaceAnimationController.swift
│   │   └── UI/
│   │       ├── CelinyButton.swift
│   │       └── CelinyCard.swift
│   ├── Screens/
│   │   ├── Onboarding/
│   │   │   ├── WelcomeView.swift
│   │   │   ├── PermissionsView.swift
│   │   │   └── CalibrationView.swift
│   │   ├── Main/
│   │   │   └── MainView.swift
│   │   ├── Conversation/
│   │   │   └── ConversationView.swift
│   │   ├── Training/
│   │   │   └── TrainingView.swift
│   │   ├── Memories/
│   │   │   └── MemoriesView.swift
│   │   └── Settings/
│   │       └── SettingsView.swift
│   ├── Services/
│   │   ├── FaceTrackingManager.swift    # ARKit face tracking
│   │   ├── AudioManager.swift           # Real-time audio
│   │   ├── VoiceManager.swift           # Speech synthesis
│   │   ├── MemoryManager.swift          # 3-tier memory system
│   │   ├── EmbeddingEngine.swift        # Core ML for search
│   │   └── PreferenceLearner.swift      # Adaptive AI
│   ├── Data/
│   │   ├── CoreDataStack.swift
│   │   └── Models/
│   │       ├── UserProfile.swift
│   │       ├── Session.swift
│   │       ├── Memory.swift
│   │       └── BehaviorSignal.swift
│   └── Resources/
│       ├── Assets.xcassets
│       └── Info.plist
└── Celiny.xcodeproj
```

## 🔐 Privacidade

- ✅ 100% processamento local (zero servidores)
- ✅ Dados armazenados em Core Data local
- ✅ ARKit face tracking não grava vídeo, apenas sinais
- ✅ "Apagar tudo" sempre acessível
- ✅ Nenhuma telemetria ou analytics

## 📋 Requisitos

- **iOS 16.0+** (iOS 17+ recomendado)
- **iPhone X ou superior** (TrueDepth camera para face tracking)
- **Xcode 14.0+** (Xcode 15+ recomendado)
- **Swift 5.9+**

## 🚀 Roadmap MVP

- [x] Estrutura base do projeto
- [ ] Design system (tokens, haptics, animations)
- [ ] Face component com animações
- [ ] ARKit face tracking integration
- [ ] Onboarding flow (<60s para "sentir vida")
- [ ] Tela principal com face vivendo
- [ ] Sistema de memória (3 camadas)
- [ ] Audio e voz
- [ ] Treinos micro
- [ ] Ritual diário
- [ ] Build .ipa final

## ⚠️ Nota sobre Windows

Este README assume que você está compilando em **macOS**. Se você está vendo isto no Windows:

1. **Para desenvolvimento**: Você precisará de um Mac com Xcode para compilar apps iOS nativos
2. **Alternativa**: Use um serviço de build em nuvem como:
   - GitHub Actions (com runners macOS)
   - Codemagic
   - Bitrise

O código Swift que estou criando pode ser editado no Windows, mas a compilação final para .ipa **requer macOS + Xcode**.
