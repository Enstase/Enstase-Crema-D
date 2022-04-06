//
//  ViewController.swift
//  Sound
//
//  Created by Martina Esposito on 05/04/22.
//


import SwiftUI

let numberOfSamples: Int = 10

struct ContentView: View {
    
    @ObservedObject var startAudio : SoundAnalyzerController
    @State var tap = false
    
    @ObservedObject var mic = MicrophoneMonitor(numberOfSamples: numberOfSamples)
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 50) / 2 // between 0.1 and 25
        
        return CGFloat(level * (200 / 25)) // scaled to max at 300 (our height of our bar)
    }
    
    var body: some View {
        VStack {
            
            Text("Emotions:")
                .font(.title2)
            
            CircleView(color: startAudio.color,count: funcCount(), tap: $tap)
                .frame(width: 300, height: 300)
                .padding()
            
            Text(tap == false ? "No audio" : (funcCount() > 4 ? "speak louder please" : startAudio.transcriberText))

            Spacer()
            
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white, lineWidth: 3)
                    .opacity(0.3)
                    .frame(width: 400, height: 200)
                    
                if tap {
                    
                    HStack(spacing: 4) {
                        ForEach(mic.soundSamples, id: \.self) { level in
                            
                            BarView(value: self.normalizeSoundLevel(level: level))
                        }
                    }.padding()
                } else {
                    HStack(spacing: 4) {
                        ForEach(0...9, id: \.self) { level in

                            BarView(value: 1.0)
                        }
                    }.padding()
                    
                }
            }
            
            Spacer()
            
            Button{
                tap.toggle()
                
            }label: {
                if tap {
                    
                    Image(systemName: "pause")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.red)
                } else {
                    
                    Image(systemName: "play.fill")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.red)
                }
            }.padding()
            Text("Press the button to start!")
                .font(.title3)
                .fontWeight(.semibold)
        }
    }
    func arrayLevel(level: Float) -> [Double] {
        let level = max(0.2, CGFloat(level) + 50) / 2 // between 0.1 and 25
        
        var arrayLevel : [Double] = []
        arrayLevel.append(CGFloat(level * (200 / 25)))

        return arrayLevel
    }

    func funcCount()-> Int{

//        var text: String = ""
        var count = 0
        
        for level in mic.soundSamples{

            for level2 in arrayLevel(level: level){
                
                if level2 < 50 {

                    count += 1
                }
            }
//            if count > 4 {
//
//                text = "speak louder please"
//            } else {
//
//                text = startAudio.transcriberText
//            }
        }
        return count
    }
}

struct BarView: View {
    var value: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(gradient: Gradient(colors: [.purple, .blue]),
                                     startPoint: .top,
                                     endPoint: .bottom))
                .frame(width: (UIScreen.main.bounds.width - CGFloat(numberOfSamples) * 9) / CGFloat(numberOfSamples), height: value)
        }
    }
}


