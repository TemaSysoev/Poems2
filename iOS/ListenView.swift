//
//  ListenView.swift
//  Poems2 (iOS)
//
//  Created by Tema Sysoev on 17.06.2021.
//

import SwiftUI
import Speech

struct ListenView: View {
    
    
    @ObservedObject var speechRec = SpeechRec()
    @ObservedObject private var mic = MicrophoneMonitor(numberOfSamples: 15)
    @Environment(\.presentationMode) var presentationMode
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(0.1, CGFloat(level) + 20) / 2 // between 0.1 and 25
        
        return CGFloat(level * (15)) // scaled to max at 300 (our height of our bar)
    }
    @State var language: String
    @State var author: String
    @State var title: String
    @State var inputText: String
    @State var selectedIndex = Int()
    @State var fourLines = ["""
    """]
    @State var checkAnswer = "Слушаю..."
    @State var debugText = ""
    @State var paragraphStep = 0
    
    @State var userText = ""
    @State var statusColor = Color.accentColor
    
    @State var searchText = ""
    @State var complete = "false"
    
    @State var c1out = ""
    @State var c2out = ""
    @State var misOut = ""
    @State var debug = false
    
    @State var help = true
    @State var showSettings = false
    @State var addNew = false
    
    @State var slicedText = ""
    
   
    @State var showingSheet = false
    
    @State var selectedLanguage = "Rus"
    var body: some View {
        ZStack() {
      VStack{
          
          Spacer()
          Button(action: {}, label: {
              if slicedText == ""{
                  Text(getFirstAndEndWord(s: fourLines[paragraphStep])[0] + " ... ")
                      .font(.system(.largeTitle, design: .serif))
                      
                      .foregroundColor(Color.primary)
                      .onChange(of: inputText, perform: { value in
                          fourLineParse()
                      })
                      .onAppear{
                          fourLineParse()
                      }
              }else{
                  
                  Text(slicedText)
                      .font(.system(.largeTitle, design: .serif))
                      .frame(maxWidth: .infinity)
                      .padding()
                      .animation(.easeIn)
                      .foregroundColor(Color.primary)
                      .multilineTextAlignment(.center)
                      .onChange(of: inputText, perform: { value in
                          fourLineParse()
                      })
                      .onAppear{
                          fourLineParse()
                      }
              }
              
              
              
              
          })
          
          .buttonStyle(BorderlessButtonStyle())
          .padding()
          
          Spacer()
          VStack {
              switch checkAnswer{
              case "Все верно":
                  Text("Все верно")
              case "Слушаю...":
                  Text("")
              case "Ошибка":
                  Button(action: {
                      if paragraphStep < fourLines.count-1{
                          paragraphStep += 1
                          self.speechRec.stop()
                          debugText = ""
                          userText = " "
                          self.speechRec.start()
                      }else{
                          
                          complete = "true"
                          
                          
                      }
                  }, label: {
                      Text("Я сказал всё правильно")
                          .foregroundColor(Color.red)
                  })
                  .buttonStyle(BorderlessButtonStyle())
              default:
                  Text("Wrong key \(checkAnswer)")
              }
              HStack{
                  
                  Button(action: {
                      self.speechRec.stop()
                      
                      userText = " "
                      debugText = " "
                      self.speechRec.start()
                  }, label: {
                      ZStack{
                          
                          Circle()
                              
                              .foregroundColor(Color.red.opacity(0.3))
                              .frame(width: 50, height: 50)
                          
                          Image(systemName: "arrow.uturn.backward")
                              .foregroundColor(Color.red)
                              .imageScale(.large)
                          
                          
                      }
                  })
                  .buttonStyle(BorderlessButtonStyle())
                  .accessibility(label: Text("Заново это четверостишие"))
                  
                 
                  
                  Button(action: {
                      if paragraphStep < fourLines.count-1{
                          paragraphStep += 1
                          self.speechRec.stop()
                          debugText = ""
                          userText = " "
                          self.speechRec.start()
                      }else{
                          help = true
                          complete = "true"
                          
                          
                          
                      }
                  }, label: {
                      ZStack{
                          
                          Circle()
                              
                              .foregroundColor(Color.green.opacity(0.3))
                              .frame(width: 50, height: 50)
                          
                          Image(systemName: "arrow.right")
                              .foregroundColor(Color.green)
                              .imageScale(.large)
                          
                          
                      }
                  })
                  
                  .buttonStyle(BorderlessButtonStyle())
                  .accessibility(label: Text("Следующее четверостишие"))
                  
              }
              .padding(.bottom, 30)
              .contextMenu{
                  Button(action: {
                      debug = true
                  }, label: {
                      Text("Debug")
                          .foregroundColor(Color.red)
                  })
                  .buttonStyle(BorderlessButtonStyle())
              }
              if debug {
                  Text(c1out)
                  Text(c2out)
                  Text(misOut)
                  TextField("Ручной ввод", text: $debugText)
                      .onChange(of: debugText, perform: { value in
                          checkAnswer = Check(language: language).compare(s1: debugText, s2: fourLines[paragraphStep])
                          statusColor = UIOutput().getColor(checkAnswer)
                      })
                  Text(userText)
                      .onAppear {
                          self.speechRec.start()
                      }
                      
                      .onChange(of: speechRec.recognizedText, perform: { value in
                          userText = speechRec.recognizedText
                          checkAnswer = Check(language: language).compare(s1: userText, s2: fourLines[paragraphStep])
                          c1out = Check(language: language).simplify(userText)
                          c2out = Check(language: language).simplify(fourLines[paragraphStep])
                          statusColor = UIOutput().getColor(checkAnswer)
                          
                      })
                      .padding()
              }
              
          }
          .padding()
         
             
              
              
              
          
          .onChange(of: speechRec.recognizedText, perform: { value in
              userText = speechRec.recognizedText
              checkAnswer = Check(language: language).compare(s1: userText, s2: fourLines[paragraphStep])
              slicedText = UIOutput().slice(s1: userText, s2: fourLines[paragraphStep])
              if userText.contains("заново") {
                  if userText.contains("весь стих"){
                      paragraphStep = 0
                  }
                  self.speechRec.stop()
                  
                  userText = " "
                  debugText = " "
                  self.speechRec.start()
              }
          })
          
      }
            /*ForEach(mic.soundSamples, id: \.self) { level in
                BarView(value: self.normalizeSoundLevel(level: level), color: statusColor)
                    .frame(height: 300)
                
            }*/
        }
    }
    
    func fourLineParse() {
        var tmpLines = inputText.components(separatedBy: .newlines)
        var tmpFourLines = ["""
        """]
        var tmpCounter = 0
        var pararaphCounter = 0
        for i in 0..<tmpLines.count{
            tmpLines[i] = tmpLines[i].replacingOccurrences(of: "    ", with: "")
            
            if tmpCounter < 4{
                tmpFourLines[pararaphCounter] += (tmpLines[i] + "\n")
                tmpCounter += 1
            }else{
                pararaphCounter += 1
                tmpCounter = 1
                tmpFourLines.append(tmpLines[i] + "\n")
            }
        }
        fourLines = tmpFourLines
    }
    func getFirstAndEndWord(s: String) -> [String]{
        let splited = s.components(separatedBy: .whitespaces)
        var result = [String]()
        result.append(splited[0])
        result.append(splited[splited.endIndex-1])
        return result
    }
    func misL(s1: String, s2: String) -> Int {
        if s1.count*s2.count != 0 {
            let a1 = Array(s1)
            let a2 = Array(s2)
            
            var f = [[Int]](repeating: [Int](repeating: 0, count: s2.count + 1), count: s1.count + 1)
            for i in 0...s1.count {
                for j in 0...s2.count{
                    if i*j == 0 {
                        f[i][j] = i+j
                    }else{
                        f[i][j] = 0
                    }
                }
            }
            for i in 1...s1.count {
                for j in 1...s2.count{
                    if a1[i-1] == a2[j-1] {
                        f[i][j] = f[i-1][j-1]
                    }else{
                        f[i][j] = 1 + min(f[i-1][j], f[i][j-1], f[i-1][j-1])
                    }
                }
            }
            
            
            return f[s1.count][s2.count]
        } else{
            return max(s1.count, s2.count)
        }
    }
}



class SpeechRec: ObservableObject {
    @Published private(set) var recognizedText = ""
    
    var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    func start() {
        self.recognizedText = ""
        SFSpeechRecognizer.requestAuthorization { status in
            self.startRecognition()
        }
    }
    //    func switchLanguadge(to: String){
    //        print(to)
    //        switch to {
    //        case "Rus":
    //            speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
    //        default:
    //            speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
    //        }
    //
    //    }
    func stop() {
        self.audioEngine.stop()
        self.recognitionRequest?.endAudio()
        self.recognitionTask?.cancel()
        self.recognitionTask = nil
        self.recognizedText = " "
        
    }
    func startRecognition() {
        
        do {
            if let recognitionTask = recognitionTask {
                recognitionTask.cancel()
                self.recognitionTask = nil
            }
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            guard let recognitionRequest = recognitionRequest else { return }
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    self.recognizedText = result.bestTranscription.formattedString
                }
            }
            
            let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
        }
        
        catch {
            
        }
    }
}
struct BarView: View {
    var value: CGFloat
    var color: Color
    var body: some View {
        
        Circle()
            .fill(RadialGradient(gradient: Gradient(colors: [color.opacity(0.0), color.opacity(0.1)]), center: .center, startRadius: 0, endRadius: 300))
            .frame(width: value*1.5, height: value*1.5)
            //.rotationEffect(.degrees(Double(arc4random_uniform(UInt32(180)))))
            .offset(x: CGFloat(arc4random_uniform(UInt32(15))), y: CGFloat(arc4random_uniform(UInt32(15))))
            .blur(radius: 3.0)
        .animation(.spring())
        
        
    }
}
