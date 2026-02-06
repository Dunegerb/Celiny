import Foundation
import ARKit
import Vision
import CoreImage

/// Real-time face tracking usando ARKit (TrueDepth) com fallback para Vision
class FaceTrackingManager: NSObject, ObservableObject {
    
    // MARK: - Published State
    
    @Published var currentExpression: FaceExpression = .neutral
    @Published var headPose: HeadPose = HeadPose()
    @Published var mouthOpenAmount: Float = 0.0
    @Published var smileAmount: Float = 0.0
    @Published var eyeBlinkLeft: Float = 0.0
    @Published var eyeBlinkRight: Float = 0.0
    @Published var isTracking: Bool = false
    
    // MARK: - ARKit Session
    
    private var arSession: ARSession?
    private var arConfiguration: ARFaceTrackingConfiguration?
    private var useARKit: Bool = false
    
    // MARK: - Vision Fallback
    
    private var visionRequests: [VNRequest] = []
    private var captureSession: AVCaptureSession?
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupFaceTracking()
    }
    
    // MARK: - Setup
    
    private func setupFaceTracking() {
        // Verificar se TrueDepth está disponível
        if ARFaceTrackingConfiguration.isSupported {
            setupARKit()
        } else {
            setupVisionTracking()
        }
    }
    
    private func setupARKit() {
        useARKit = true
        arSession = ARSession()
        arSession?.delegate = self
        
        arConfiguration = ARFaceTrackingConfiguration()
        arConfiguration?.isLightEstimationEnabled = false
        arConfiguration?.maximumNumberOfTrackedFaces = 1
        
        print("✅ ARKit TrueDepth face tracking configurado")
    }
    
    private func setupVisionTracking() {
        useARKit = false
        
        // Configurar Vision para detectar faces
        let faceDetectionRequest = VNDetectFaceRectanglesRequest { [weak self] request, error in
            guard let results = request.results as? [VNFaceObservation] else { return }
            self?.processVisionResults(results)
        }
        
        let faceLandmarksRequest = VNDetectFaceLandmarksRequest { [weak self] request, error in
            guard let results = request.results as? [VNFaceObservation] else { return }
            self?.processVisionLandmarks(results)
        }
        
        visionRequests = [faceDetectionRequest, faceLandmarksRequest]
        
        setupCaptureSession()
        
        print("⚠️ ARKit não disponível. Usando Vision framework fallback")
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .high
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("❌ Falha ao configurar capture session")
            return
        }
        
        captureSession?.addInput(input)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession?.addOutput(videoOutput)
    }
    
    // MARK: - Public Control
    
    func start() {
        if useARKit {
            guard let configuration = arConfiguration else { return }
            arSession?.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            print("▶️ ARKit tracking iniciado")
        } else {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
            print("▶️ Vision tracking iniciado")
        }
        
        DispatchQueue.main.async {
            self.isTracking = true
        }
    }
    
    func stop() {
        if useARKit {
            arSession?.pause()
        } else {
            captureSession?.stopRunning()
        }
        
        DispatchQueue.main.async {
            self.isTracking = false
        }
    }
    
    // MARK: - ARKit Data Processing
    
    private func processARFace(_ anchor: ARFaceAnchor) {
        let blendShapes = anchor.blendShapes
        
        // Extrair blend shapes
        let mouthOpen = blendShapes[.jawOpen]?.floatValue ?? 0.0
        let smileLeft = blendShapes[.mouthSmileLeft]?.floatValue ?? 0.0
        let smileRight = blendShapes[.mouthSmileRight]?.floatValue ?? 0.0
        let blinkLeft = blendShapes[.eyeBlinkLeft]?.floatValue ?? 0.0
        let blinkRight = blendShapes[.eyeBlinkRight]?.floatValue ?? 0.0
        
        // Atualizar estado
        DispatchQueue.main.async {
            self.mouthOpenAmount = mouthOpen
            self.smileAmount = (smileLeft + smileRight) / 2.0
            self.eyeBlinkLeft = blinkLeft
            self.eyeBlinkRight = blinkRight
            
            // Atualizar head pose
            let transform = anchor.transform
            self.headPose = HeadPose(
                pitch: Float(atan2(transform.columns.2.y, transform.columns.2.z)),
                yaw: Float(atan2(-transform.columns.2.x, sqrt(pow(transform.columns.2.y, 2) + pow(transform.columns.2.z, 2)))),
                roll: Float(atan2(transform.columns.1.x, transform.columns.0.x))
            )
            
            // Determinar expressão
            self.currentExpression = self.determineExpression(
                mouthOpen: mouthOpen,
                smile: self.smileAmount,
                blinkLeft: blinkLeft,
                blinkRight: blinkRight
            )
        }
    }
    
    // MARK: - Vision Data Processing
    
    private func processVisionResults(_ results: [VNFaceObservation]) {
        guard let face = results.first else {
            DispatchQueue.main.async {
                self.isTracking = false
            }
            return
        }
        
        DispatchQueue.main.async {
            self.isTracking = true
            // Vision fornece menos dados, usar heurísticas simples
            self.currentExpression = .neutral
        }
    }
    
    private func processVisionLandmarks(_ results: [VNFaceObservation]) {
        guard let face = results.first,
              let landmarks = face.landmarks else { return }
        
        // Extrair dados de landmarks
        if let mouth = landmarks.outerLips {
            // Calcular abertura da boca baseado na geometria
            let mouthHeight = calculateMouthHeight(from: mouth)
            DispatchQueue.main.async {
                self.mouthOpenAmount = mouthHeight
            }
        }
        
        // Processar outros landmarks...
    }
    
    private func calculateMouthHeight(from lips: VNFaceLandmarkRegion2D) -> Float {
        let points = lips.normalizedPoints
        guard points.count >= 6 else { return 0 }
        
        // Distância vertical entre topo e base da boca
        let topY = points[3].y
        let bottomY = points[9].y
        return Float(abs(topY - bottomY))
    }
    
    // MARK: - Expression Determination
    
    private func determineExpression(
        mouthOpen: Float,
        smile: Float,
        blinkLeft: Float,
        blinkRight: Float
    ) -> FaceExpression {
        
        // Lógica de decisão baseada em thresholds calibrados
        if smile > 0.5 {
            return .happy
        } else if mouthOpen > 0.6 {
            return .surprised
        } else if mouthOpen > 0.2 && mouthOpen < 0.4 {
            return .speaking
        } else if blinkLeft > 0.8 && blinkRight > 0.8 {
            return .thinking
        } else {
            return .neutral
        }
    }
}

// MARK: - ARSessionDelegate

extension FaceTrackingManager: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor else { return }
        processARFace(faceAnchor)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("❌ ARSession error: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.isTracking = false
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension FaceTrackingManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let imageRequestHandler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .leftMirrored,
            options: [:]
        )
        
        do {
            try imageRequestHandler.perform(visionRequests)
        } catch {
            print("❌ Vision request error: \(error)")
        }
    }
}

// MARK: - Supporting Types

struct HeadPose {
    var pitch: Float = 0  // Cima/baixo
    var yaw: Float = 0    // Esquerda/direita
    var roll: Float = 0   // Inclinação lateral
}
