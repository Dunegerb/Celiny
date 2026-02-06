# 🔧 Troubleshooting - Celiny

## ❌ App Fecha ao Pedir Permissões de Câmera/Microfone

### **Problema:**
Ao clicar em "Permitir" para câmera ou microfone, o app fecha automaticamente.

### **Causa:**
Apps instalados via Sideloadly sem assinatura adequada podem ter restrições de sandbox do iOS.

### **Soluções:**

#### **Opção 1: Pular Permissões (Temporário)**
1. Abra o app
2. **NÃO clique em "Permitir"** para câmera/microfone
3. Vá direto para Settings do iOS
4. **iOS Settings → Celiny**
5. Ative Camera e Microphone manualmente
6. Volte ao app
7. Force quit e reabra

#### **Opção 2: Permitir via Settings ANTES de abrir**
1. Antes de abrir o Celiny pela primeira vez
2. Vá em **iOS Settings → Celiny**
3. Ative Camera e Microphone
4. **Agora** abra o app
5. Ele detectará as permissões já concedidas

#### **Opção 3: Reinstalar com Assinatura**
Se você tem Apple Developer Account pago:
1. Configure signing no Sideloadly
2. Use seu Team ID
3. Reinstale o app
4. Permissões funcionarão normalmente

---

## ⚠️ Por Que Isso Acontece?

Quando um app iOS solicita permissões sensíveis (câmera, microfone, localização), o iOS:
1. Mostra um alerta de sistema
2. Executa verificações de sandbox
3. **Verifica assinatura do app**

Apps instalados via Sideloadly com conta gratuita:
- ✅ Podem pedir notificações (funciona!)
- ❌ Podem crashar ao pedir câmera/mic (restrição do iOS)

**Workaround**: Permitir manualmente via Settings iOS.

---

## 📱 Como Usar o App SEM Permissões

Mesmo sem câmera/microfone, você pode:
- ✅ Ver a interface completa
- ✅ Navegar entre telas
- ✅ Ver animações da face
- ✅ Testar haptics
- ✅ Explorar o design

**O MVP foi feito para demonstrar a UX e design, não funcionalidade completa!**

---

## 🔄 Ordem Recomendada no iPhone XS

### **Setup Inicial:**
```
1. Conectar iPhone via USB
2. Instalar com Sideloadly
3. FECHAR o app se abriu automaticamente
4. IR PARA: iOS Settings → Celiny
5. ATIVAR: Camera, Microphone
6. Trust certificado (VPN & Device Management)
7. AGORA SIM: Abrir Celiny
```

### **Fluxo no App:**
```
1. Welcome → "Começar"
2. Permissions:
   - Notificações: Clique "Permitir" (funciona!)
   - Câmera: Já estará ✅ (ativado previamente)
   - Microfone: Já estará ✅ (ativado previamente)
3. Calibration → Siga os 4 passos
4. Main Screen → Celiny vivo!
```

---

## 🎯 Permissões Manuais - Passo a Passo Visual

### **iOS Settings → Celiny:**

```
⚙️ Settings
  └── 📱 Celiny
       ├── 📷 Camera          [ATIVAR]
       ├── 🎤 Microphone      [ATIVAR]
       └── 🔔 Notifications   [Opcional]
```

**Importante:** Ative ANTES de abrir o app pela primeira vez!

---

## ✅ O Que Funciona Perfeitamente

- ✅ **Notificações**: Pode permitir dentro do app
- ✅ **Haptics**: Funcionam 100%
- ✅ **Animações**: Todas as transições
- ✅ **Face Component**: Expressões e blinking
- ✅ **Design System**: Cores, espaçamentos, tipografia
- ✅ **Onboarding Flow**: Todas as telas
- ✅ **Bottom Navigation**: Todas as telas

---

## 🚀 Solução Definitiva (Futuro)

Para produção, o app precisaria:
1. **Apple Developer Account pago** ($99/ano)
2. **App Store distribution** ou TestFlight
3. **Entitlements adequados**
4. **Code signing completo**

**Este MVP** foi feito para demonstração de UX/Design, não distribuição comercial.

---

## 💡 Dica Pro

Se quiser testar face tracking de verdade:
1. **Use simulação**: O app já simula expressões aleatórias
2. **Veja o design**: Foco está na UX neurocientífica
3. **Observe detalhes**: Haptics, timings, cores, spacing

O verdadeiro valor do Celiny está no **design thinking** por trás! 🧠✨

---

## 📞 Ainda com Problemas?

Se mesmo seguindo esses passos o app não funcionar:
1. Force quit o app (swipe up no app switcher)
2. Delete o app
3. Reinstale via Sideloadly
4. **ANTES de abrir**: Configure permissões no Settings
5. Abra o app

---

**Resumo**: Sideloadly + iOS = permissões sensíveis precisam ser ativadas via Settings primeiro! 🎯
