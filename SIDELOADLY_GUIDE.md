# 📲 Como Baixar e Instalar o .ipa com Sideloadly

## 🎯 Passo a Passo Completo

### 1️⃣ Disparar o Build Automático

Existem 3 formas de iniciar a compilação:

#### Opção A: Push para Main (Automático)
Sempre que você fizer push para a branch `main`, o workflow roda automaticamente.

#### Opção B: Manual via GitHub (Recomendado)
1. Vá para: https://github.com/Dunegerb/Celiny/actions
2. Clique em **"Build iOS App"** na lista de workflows
3. Clique no botão **"Run workflow"** (canto superior direito)
4. Selecione branch: `main`
5. Clique em **"Run workflow"** verde

#### Opção C: Pull Request
Criar um PR também dispara o build.

---

### 2️⃣ Aguardar a Compilação

⏱️ **Tempo estimado**: 5-10 minutos

1. Vá para https://github.com/Dunegerb/Celiny/actions
2. Clique no workflow que está rodando (bolinha amarela 🟡)
3. Acompanhe o progresso:
   - ✅ Checkout repository
   - ✅ Setup Xcode
   - ✅ Install XcodeGen
   - ✅ Generate Xcode Project
   - ✅ Build App
   - ✅ Build for Archive
   - ✅ Export IPA
   - ✅ Upload IPA as Artifact

Quando tudo ficar verde ✅, o build está pronto!

---

### 3️⃣ Baixar o .ipa

1. No GitHub Actions, clique no workflow **concluído** (✅ verde)
2. Role para baixo até a seção **"Artifacts"**
3. Você verá:
   - 📦 **Celiny-iOS-App** - Clique para baixar
   - 📄 build-logs (opcional, para debug)
4. Baixe o arquivo ZIP
5. Extraia o ZIP → você terá `Celiny.ipa`

---

### 4️⃣ Instalar com Sideloadly

#### Preparação:
- ✅ Sideloadly instalado no Windows
- ✅ iPhone conectado via USB
- ✅ iTunes/Apple Devices instalado (para drivers)
- ✅ iPhone desbloqueado e em "Confiar neste computador"

#### Passos no Sideloadly:

1. **Abra o Sideloadly**

2. **Configure:**
   - **IPA File**: Arraste `Celiny.ipa` ou clique Browse
   - **Device**: Selecione seu iPhone na lista
   - **Apple Account**: Coloque seu Apple ID (pode ser gratuito!)
     - Email: seu@email.com
     - Password: sua senha (ou senha de app se tiver 2FA)

3. **Opções Avançadas** (ícone engrenagem):
   - ✅ **Remove PlugIns** (desmarque)
   - ✅ **Remove UISupportedDevices** (marque)
   - Bundle ID: pode deixar padrão ou mudar para `com.celiny.app.sideload`

4. **Clique em "Start"**

5. **Aguarde:**
   - Sideloadly vai:
     - Assinar o app com seu certificado
     - Instalar no iPhone
     - Tempo: ~2-5 minutos

6. **No iPhone:**
   - O ícone do Celiny aparecerá na Home Screen
   - **NÃO ABRA AINDA!**

---

### 5️⃣ Confiar no Certificado (Importante!)

1. No iPhone, vá para:
   ```
   Settings → General → VPN & Device Management
   ```

2. Você verá seu Apple ID na seção "Developer App"

3. Toque no seu email

4. Toque em **"Trust [seu email]"**

5. Confirme **"Trust"** no popup

---

### 6️⃣ Abrir o Celiny! 🎉

1. Encontre o app **Celiny** na Home Screen
2. Toque para abrir
3. **Conceda permissões** quando solicitado:
   - ✅ Câmera
   - ✅ Microfone
   - ✅ Notificações (opcional)

4. Siga o onboarding:
   - Tela 1: "Vamos treinar juntos" → **Começar**
   - Tela 2: Permita câmera e microfone
   - Tela 3: Calibração (vire a cabeça, sorria, fale)
   - Em <60 segundos você sentirá Celiny viva! ✨

---

## 🔄 Renovar Certificado (A Cada 7 Dias)

Apps instalados com conta Apple ID gratuita expiram em **7 dias**.

**Quando expirar:**
1. Baixe o `.ipa` novamente (ou use o mesmo)
2. Reinstale com Sideloadly (repita passo 4)
3. Seus dados **NÃO SÃO perdidos** (Core Data persiste)

**Para evitar expiração:**
- Considere Apple Developer Account pago ($99/ano) = apps válidos por 1 ano
- Ou use AltStore (renova automaticamente a cada 7 dias via WiFi)

---

## 🐛 Troubleshooting

### Erro: "Unable to find device"
- Reconecte o cabo USB
- Confie no computador no iPhone
- Reinicie o iTunes/Apple Devices

### Erro: "Your session has expired"
- Se tiver 2FA, use **App-Specific Password**:
  1. appleid.apple.com → Security
  2. Generate Password
  3. Use no Sideloadly

### Erro: "Installation failed"
- Verifique se Bundle ID é único
- Delete app antigo do iPhone antes
- Tente mudar Bundle ID para algo único

### App abre e fecha imediatamente
- Certifique-se que confiou no certificado (passo 5)
- Veja Settings → General → VPN & Device Management

### Câmera não abre
- Vá em Settings → Celiny
- Verifique se Camera permission está ON
- Delete e reinstale se necessário

---

## 📊 Status do Build

Veja o status em tempo real:
👉 https://github.com/Dunegerb/Celiny/actions

Badge de status (adicione ao README):
```markdown
![iOS Build](https://github.com/Dunegerb/Celiny/actions/workflows/build-ios.yml/badge.svg)
```

---

## 🚀 Melhorias Futuras do Workflow

Posso adicionar depois:
- [ ] TestFlight automatic upload
- [ ] Notificação quando build ficar pronto
- [ ] Múltiplos esquemas (Debug/Release)
- [ ] Automatic versioning
- [ ] Run tests before build

---

## 💡 Dicas Pro

1. **Mantenha o .ipa salvo** - você pode reinstalar sem rebuild
2. **Use AltStore** se quiser auto-refresh dos 7 dias
3. **Doe $99/ano** para Apple Developer se quiser evitar renovação
4. **Check Actions tab** semanalmente para ver se há novos builds

---

**Pronto!** Agora você tem um pipeline completo:
```
Push código → GitHub Actions compila → Baixa .ipa → Sideloadly instala → Celiny no iPhone
```

Sem precisar de Mac! 🎉
