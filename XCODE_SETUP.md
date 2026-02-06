# 🛠️ Setup do Projeto Xcode - Celiny

Este guia detalha como configurar o projeto Xcode para compilar Celiny.

## ⚠️ Requisitos

- **macOS** (Big Sur ou superior)
- **Xcode 14.0+** (recomendo Xcode 15)
- **Apple Developer Account** (gratuita para teste em dispositivo próprio)
- **iPhone X ou superior** (para face tracking com TrueDepth)

## 📦 Passo 1: Criar Projeto no Xcode

1. Abra o Xcode
2. File → New → Project
3. Selecione **iOS → App**
4. Configure:
   - **Product Name**: `Celiny`
   - **Team**: Selecione seu Apple Developer Team
   - **Organization Identifier**: `com.celiny` (ou seu próprio)
   - **Bundle Identifier**: `com.celiny.app`
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: Nenhum (vamos criar Core Data depois)
5. Salve no diretório: `C:\Users\Usuário\Documents\antigravityprojects\Celiny`

## 📁 Passo 2: Organizar Arquivos

Arraste os arquivos Swift do projeto para o Xcode seguindo esta estrutura:

```
Celiny/
├── App/
│   └── CelinyApp.swift
├── DesignSystem/
│   ├── DesignTokens.swift
│   ├── HapticsEngine.swift
│   └── AnimationSystem.swift
├── Components/
│   ├── Face/
│   │   └── FaceView.swift
│   └── UI/
│       ├── CelinyButton.swift
│       └── CelinyCard.swift
├── Screens/
│   ├── Onboarding/
│   │   ├── WelcomeView.swift
│   │   ├── PermissionsView.swift
│   │   └── CalibrationView.swift
│   └── Main/
│       └── MainView.swift
└── Resources/
    └── Info.plist
```

**Importante**: No Xcode, arraste a pasta `Celiny` inteira para o Project Navigator e selecione:
- ✅ **Copy items if needed**
- ✅ **Create groups** (não "Create folder references")
- ✅ **Add to targets: Celiny**

## ⚙️ Passo 3: Configurar Capabilities

1. Selecione o projeto raiz (ícone azul "Celiny") no Project Navigator
2. Selecione o target "Celiny"
3. Vá para aba **Signing & Capabilities**
4. Adicione as capabilities:

### 3.1 Camera Usage
- Já configurado via `Info.plist` (NSCameraUsageDescription)

### 3.2 ARKit (Opcional mas recomendado)
- Clique em **+ Capability**
- Adicione **ARKit**

### 3.3 Background Modes (Para audio)
- Clique em **+ Capability**
- Adicione **Background Modes**
- Marque **Audio, AirPlay, and Picture in Picture**

## 📲 Passo 4: Configurar Build Settings

1. No target "Celiny", vá para **Build Settings**
2. Procure por "iOS Deployment Target"
3. Configure para **iOS 16.0** (ou superior)
4. Procure por "Swift Language Version"
5. Confirme que está em **Swift 5** ou superior

## 🎨 Passo 5: Assets (Opcional)

Se quiser customizar ícone e cores:

1. Abra **Assets.xcassets**
2. Adicione um **Color Set** chamado `LaunchScreenBackground`
3. Configure cor: `#0A0A0E` (hex dark)

## 🔧 Passo 6: Resolver Imports e Erros

O Xcode pode mostrar alguns erros iniciais. Resolvendo:

### 6.1 UserNotifications
No topo de `PermissionsView.swift`, adicione:
```swift
import UserNotifications
```

### 6.2 Compilar pela primeira vez
- Pressione **⌘B** para compilar
- Resolva erros de compilação que aparecerem (geralmente imports faltando)

## 🏃 Passo 7: Rodar no Simulador

1. No topo do Xcode, selecione **iPhone 14 Pro** (ou superior)
2. Pressione **⌘R** para build & run
3. O app deve abrir no simulador

**⚠️ Nota**: No simulador, face tracking **NÃO funciona**. Você verá apenas animações simuladas.

## 📱 Passo 8: Rodar em Dispositivo Real

1. Conecte seu iPhone via cabo USB
2. No Xcode, selecione seu iPhone no dropdown
3. Se aparecer "Untrusted Developer":
   - No iPhone: Settings → General → VPN & Device Management
   - Confie no seu certificado de desenvolvedor
4. Pressione **⌘R**
5. **Conceda permissões** de câmera e microfone quando solicitado

## 📦 Passo 9: Gerar .ipa para Instalação

### Via Xcode GUI:

1. **Product → Archive**
2. Aguarde compilação (pode demorar alguns minutos)
3. Window → Organizer → Archives
4. Selecione o archive recente
5. **Distribute App**
6. Escolha:
   - **Development** (para instalar em seus próprios dispositivos)
   - ou **Ad Hoc** (para distribuir para até 100 dispositivos de teste)
7. Siga o wizard:
   - Selecione seu Team
   - Deixe opções padrão
   - **Export** e escolha onde salvar
8. Receba o arquivo `.ipa`!

### Via Linha de Comando (Terminal no Mac):

```bash
# Build archive
xcodebuild -scheme Celiny \
  -archivePath ./build/Celiny.xcarchive \
  clean archive

# Export IPA
xcodebuild -exportArchive \
  -archivePath ./build/Celiny.xcarchive \
  -exportPath ./build \
  -exportOptionsPlist ExportOptions.plist
```

Você precisará criar um `ExportOptions.plist` com:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>SEU_TEAM_ID</string>
</dict>
</plist>
```

## 🐛 Troubleshooting

### Erro: "Code signing"
- Vá para Signing & Capabilities
- Certifique-se que seu Team está selecionado
- Marque "Automatically manage signing"

### Erro: "Module not found"
- Verifique imports no topo dos arquivos Swift
- Rebuild: **⌘⇧K** (Clean) e depois **⌘B** (Build)

### Face não aparece / Tela preta
- Verifique se `CelinyApp.swift` está configurado como `@main`
- Verifique se o `Info.plist` está no target

### Haptics não funcionam no simulador
- Normal! Haptics só funcionam em dispositivo real iPhone

## 🚀 Próximos Passos (Após Compilar MVP)

- [ ] Integrar ARKit real para face tracking
- [ ] Implementar Core Data para memórias
- [ ] Adicionar Core ML (modelos de embedding)
- [ ] Implementar audio com AVAudioEngine
- [ ] Voice synthesis real
- [ ] Telas de conversa, treino e memórias

## 📞 Precisa de Ajuda?

Se encontrar problemas durante o setup:

1. Verifique versão do Xcode (deve ser 14+)
2. Confirme iOS deployment target (16.0+)
3. Confira se todos os arquivos Swift estão no target
4. Limpe build folder: **⌘⇧K** e tente novamente

---

**Bônus**: Se você não tem Mac, pode usar serviços de CI/CD:

- **GitHub Actions** com runners macOS (grátis para projetos públicos)
- **Codemagic** (tem tier grátis)
- **Bitrise** (tem tier grátis)

Todos podem ser configurados para compilar automaticamente e gerar .ipa!
