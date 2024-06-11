//
//  SoundAnalizerController.swift
//  Sound
//
//  Created by Martina Esposito on 05/04/22.
//

import SoundAnalysis
import Foundation
import AVFoundation
import SwiftUI

class SoundAnalyzerController: ObservableObject {
    
    
    private let audioEngine = AVAudioEngine()
    private var soundClassifier = EmotionModel()
    var inputFormat: AVAudioFormat!
    var analyzer: SNAudioStreamAnalyzer!
    var resultsObserver = ResultsObserver()
    let analysisQueue = DispatchQueue(label: "com.apple.AnalysisQueue")
    
    
    @Published var transcriberText: String = ""
    @Published var color: Color = .white
    
    init () {
        resultsObserver.delegate = self
        inputFormat = audioEngine.inputNode.inputFormat(forBus: 0)
        
        // In the initializer I instantiate SNAudioStremAnalyzer from the SoundAnalysis framework.
        // This class allows us to analyze audio data streams
        analyzer = SNAudioStreamAnalyzer(format: inputFormat)
        
        startAudioEngine()
    }
    
    private func startAudioEngine() {
        do {
            //  I create the request that analyzes through a certain model ml the audio stream
            
            let request = try SNClassifySoundRequest(mlModel: soundClassifier.model)
            
            // I pass the request to the analyzer
            try analyzer.add(request, withObserver: resultsObserver)
        } catch {
            print("Unable to prepare request: \(error.localizedDescription)")
            return
        }
        
        audioEngine.inputNode.installTap(onBus: 1, bufferSize: 8000, format: inputFormat) { buffer, time in
            // Dispatch the analize request in a Queue
            self.analysisQueue.async {
                self.analyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
            }
        }
        
        do{
            try audioEngine.start()
        }catch( _){
            print("error in starting the Audio Engin")
        }
    }
}

protocol EmotionClassifierDelegate {
    func displayPredictionResult(identifier: String, confidence: Double)
}

extension SoundAnalyzerController: EmotionClassifierDelegate {
    func displayPredictionResult(identifier: String, confidence: Double) {
        DispatchQueue.main.async {
            
            let roundConfidence = Double(round(100*confidence)/100)
            
            if roundConfidence > 60 {
                
                switch identifier {
                    
                case "happy":
                    self.color = Color("Yellow.happy")
                    
                case "sad":
                    self.color = .blue
                    
                case "surprise":
                    self.color = .yellow
                    
                case "angry":
                    self.color = .red
                    
                case "disgust":
                    self.color = .green
                    
                case "neutral":
                    self.color = .white
                    
                case "fear":
                    self.color = .black
                    
                default:
                    self.color = .white
                    
                }
                
                self.transcriberText = ("Recognition: \(identifier) with Confidence \(roundConfidence)")
                
            }else {
                
                //self.transcriberText = ("Parla più forte")
            }
        }
    }
}

class ResultsObserver: NSObject, SNResultsObserving, ObservableObject {
    var delegate: EmotionClassifierDelegate?
    func request(_ request: SNRequest, didProduce result: SNResult) {
        
        guard let result = result as? SNClassificationResult,
              let classification = result.classifications.first else { return }
        
        let confidence = classification.confidence * 100.0
        
        if confidence > 60 {
            delegate?.displayPredictionResult(identifier: classification.identifier, confidence: confidence)
        }
    }
}
