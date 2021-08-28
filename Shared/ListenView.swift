//
//  LearnView.swift
//  Poems2 (iOS)
//
//  Created by Tema Sysoev on 17.06.2021.
//

import SwiftUI
import Speech

struct LearnView: View {
    
#if os(iOS)
    @ObservedObject var speechRec = SpeechRec()
    @ObservedObject private var mic = MicrophoneMonitor(numberOfSamples: 100)
#endif
    @Environment(\.presentationMode) var presentationMode
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(0.01, CGFloat(level) + 20) // between 0.1 and 25
        
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
    @State var typedText = ""
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
    
    @State var showPrompt = false
    @State var learningModes = ["Writing", "Speaking"]
    @State var learningMode = "Writing"
    
    var body: some View {
        ZStack() {
            
            
            VStack{
                #if os(iOS)
                Picker(selection: $learningMode, label: Text("Learning mode")){
                    ForEach(learningModes, id: \.self) {
                        Text($0)
                        
                    }
                    
                }
                .padding()
                .labelsHidden()
                .pickerStyle(.segmented)
                #endif
                Spacer()
                Button(action: {
                    showPrompt.toggle()
                }, label: {
                    if showPrompt{
                        Text(fourLines[paragraphStep])
                            .font(.system(.title, design: .serif))
                        
                            .foregroundColor(Color.primary)
                            .onChange(of: inputText, perform: { value in
                                fourLineParse()
                            })
                            .onAppear{
                                fourLineParse()
                            }
                    }else{
                        Text(getFirstAndEndWord(s: fourLines[paragraphStep])[0] + " ... " + getFirstAndEndWord(s: fourLines[paragraphStep])[1])
                            .font(.system(.largeTitle, design: .serif))
                        
                            .foregroundColor(Color.primary)
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
                    .onAppear{
#if os(iOS)
                        if learningMode == "Speaking"{
                            self.speechRec.start()
                        }
#endif
                    }
                Spacer()
                if learningMode == "Writing"{
                    TextField("Start typing", text: $typedText)
                        .onChange(of: typedText, perform: { value in
                            checkAnswer = Check(language: language).compare(s1: typedText, s2: fourLines[paragraphStep])
                            statusColor = UIOutput().getColor(checkAnswer)
                        })
                        .padding()
                }
                VStack {
                    
                    HStack{
                        
                        Button(action: {
#if os(iOS)
                            if learningMode == "Speaking"{
                                self.speechRec.stop()
                                
                                userText = " "
                                typedText = " "
                                self.speechRec.start()
                            }
#endif
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
                        
                        ZStack{
                            Circle()
                                .trim(from: 0.0, to: 0.8)
                                .stroke(style: StrokeStyle(lineWidth: 30, lineCap: .round, lineJoin: .round))
                                .foregroundColor(statusColor.opacity(0.3))
                                .frame(width: 180, height: 180)
                            
                                .rotationEffect(Angle(degrees: 126))
                            Circle()
                                .trim(from: 0.0, to: CGFloat(slicedText.count)/CGFloat(fourLines[paragraphStep].count)*0.8)
                                .stroke(style: StrokeStyle(lineWidth: 30, lineCap: .round, lineJoin: .round))
                                .foregroundColor(statusColor)
                                .frame(width: 180, height: 180)
                                .rotationEffect(Angle(degrees: 126))
                                .animation(.spring())
                            
                            switch checkAnswer{
                            case "Все верно":
                                Text("Good job!")
                            case "Слушаю...":
                                Text("Listening...")
                            case "Ошибка":
                                Button(action: {
#if os(iOS)
                                    if learningMode == "Speaking"{
                                        if paragraphStep < fourLines.count-1{
                                            paragraphStep += 1
                                            self.speechRec.stop()
                                            typedText = ""
                                            userText = " "
                                            self.speechRec.start()
                                        }else{
                                            
                                            complete = "true"
                                            
                                            
                                        }
                                    }
#endif
                                }, label: {
                                    Text("Skip")
                                        .foregroundColor(Color.red)
                                })
                                    .buttonStyle(BorderlessButtonStyle())
                            default:
                                Text("Wrong key \(checkAnswer)")
                            }
                        }
                        .padding()
                        
                        Button(action: {
#if os(iOS)
                            if paragraphStep < fourLines.count-1{
                                paragraphStep += 1
                                self.speechRec.stop()
                                typedText = ""
                                userText = " "
                                self.speechRec.start()
                            }else{
                                help = true
                                complete = "true"
                                
                                
                                
                            }
#endif
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
                       
#if os(iOS)
                        Text(userText)
                            .onAppear {
                                self.speechRec.start()
                            }
                        
                            .onChange(of: speechRec.recognizedText, perform: { value in
                                userText = speechRec.recognizedText
                                checkAnswer = Check(language: language).compare(s1: userText, s2: fourLines[paragraphStep])
                                c1out = Check(language: language).simplify(userText)
                                c2out = Check(language: language).simplify(fourLines[paragraphStep])
                                misOut = "\(misL(s1: c1out, s2: c2out))"
                                statusColor = UIOutput().getColor(checkAnswer)
                                
                            })
                            .padding()
#endif
                    }
                    
                }
                .padding()
                
                
                
                
#if os(iOS)
                
                .onChange(of: speechRec.recognizedText, perform: { value in
                    userText = speechRec.recognizedText
                    checkAnswer = Check(language: language).compare(s1: userText, s2: fourLines[paragraphStep])
                    if checkAnswer == "Все верно"{
                        paragraphStep += 1
                        self.speechRec.stop()
                        typedText = ""
                        userText = " "
                        self.speechRec.start()
                    }
                    slicedText = UIOutput().slice(s1: userText, s2: fourLines[paragraphStep])
                    if userText.contains("заново") {
                        if userText.contains("весь стих"){
                            paragraphStep = 0
                        }
                        self.speechRec.stop()
                        
                        userText = " "
                        typedText = " "
                        self.speechRec.start()
                    }
                })
#endif
                .onChange(of: typedText, perform: { value in
                    userText = typedText
                    checkAnswer = Check(language: language).compare(s1: userText, s2: fourLines[paragraphStep])
                    if checkAnswer == "Все верно"{
                        paragraphStep += 1
                       
                        typedText = ""
                        userText = " "
                      
                    }
                    slicedText = UIOutput().slice(s1: userText, s2: fourLines[paragraphStep])
                    if userText.contains("заново") {
                        if userText.contains("весь стих"){
                            paragraphStep = 0
                        }
                       
                        
                        userText = " "
                        typedText = " "
                        
                    }
                })
                
            }
            .frame(maxWidth: .infinity)
            
            
            
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
    
    var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-us"))
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
            .fill(RadialGradient(gradient: Gradient(colors: [color.opacity(1.0), color.opacity(1.0)]), center: .center, startRadius: 0, endRadius: 300))
            .frame(width: value*7, height: value*7)
        //.rotationEffect(.degrees(Double(arc4random_uniform(UInt32(180)))))
            .offset(x: CGFloat(arc4random_uniform(UInt32(100))) - 50, y: CGFloat(arc4random_uniform(UInt32(100)))-50)
        // .blur(radius: 3.0)
        //.animation(.spring())
        
        
    }
}

struct LearnView_Previews: PreviewProvider {
    static var previews: some View {
        LearnView(language: "Eng", author: "Shakespear", title: "Title", inputText: "Some cool text\nOnly for you")
        
    }
}
