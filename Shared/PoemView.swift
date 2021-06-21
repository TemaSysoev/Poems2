//
//  PoemView.swift
//  Poems2
//
//  Created by Tema Sysoev on 08.06.2021.
//

import SwiftUI

struct PoemView: View {
    @State var language: String
    @State var author: String
    @State var title: String
    @State var inputText: String
    @State var complete: Bool
    @State var selectedIndex = Int()
    @State var fourLines = ["""
    """]
    @State var checkAnswer = "Слушаю..."
    @State var debugText = ""
    @State var paragraphStep = 0
    
    @State var userText = ""
    @State var statusColor = Color.accentColor
    
    @State var searchText = ""
    
    @State var c1out = ""
    @State var c2out = ""
    @State var misOut = ""
    @State var debug = false
    
    @State var showListenView = false
    @State var showSettings = false
    @State var addNew = false
    
    @State var slicedText = ""
    
    
    @State var showingSheet = false
    
    @State var selectedLanguage = "Rus"
    
    
    @State var price = String()
    
    @State private var bookmarkedPoems = [LocalPoems]()
    
    var body: some View {
        VStack{
#if os(iOS)
            Text(author)
                .font(.system(.footnote))
                .foregroundColor(Color.accentColor)
#endif
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false){
                    
                    
                    ForEach(0..<fourLines.count, id: \.self){ index in
                        
                        
                        Text(fourLines[index])
                        
                            .id("\(index)")
                            .multilineTextAlignment(.center)
                            .font(.system(.title2, design: .serif))
                            .padding()
                            .foregroundColor(Color.primary)
                            .onChange(of: inputText, perform: { value in
                                fourLineParse()
                            })
                            .onAppear{
                                fourLineParse()
                            }
                        
                        
                        
                    }
                    
                    
                }
                
                .frame(maxWidth: .infinity)
                .foregroundColor(.black)
                
            }
#if os(iOS)
            Button(action: {
                showListenView = true
                
            }, label: {
                Text("Listen")
                    .frame(maxWidth: .infinity)
                    
                
            })
                .buttonStyle(.bordered)
                .tint(Color.accentColor)
                .controlSize(.large)
                .padding()
                .sheet(isPresented: $showListenView){
                    ListenView(language: language, author: author, title: title, inputText: inputText)
                        
                }
            
#endif
        }
        .toolbar{
            Button(action: {
                
               var bookmarked = loadBookmarked()
                bookmarked.append(title)
            saveBookmarked(s: bookmarked)
                
                    
                
                
                
            }, label: {
                if loadBookmarked().contains(title){
                    Image(systemName: "bookmark.fill")
                        .symbolRenderingMode(.multicolor)
                }else{
                    Image(systemName: "bookmark")
                }
            })
        }
#if os(iOS)
        .navigationBarTitle("\(title)", displayMode: .inline)
#endif
        
#if os(macOS)
        //.textSelection(.enabled)
        .navigationTitle("\(title)")
        .navigationSubtitle("\(author)")
#endif
        
    }
    
    static func stringify(json: Any, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
          options = JSONSerialization.WritingOptions.prettyPrinted
        }

        do {
          let data = try JSONSerialization.data(withJSONObject: json, options: options)
          if let string = String(data: data, encoding: String.Encoding.utf8) {
            return string
          }
        } catch {
          print(error)
        }

        return ""
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name,
                                                 ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        
        return nil
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

struct PoemView_Previews: PreviewProvider {
    static var previews: some View {
        PoemView(language: "RUS", author: "Пушкин А.С.", title: "Письмо Татьяны к Онегину", inputText: "Я к вам пишу – чего же боле?\nЧто я могу еще сказать?\nТеперь, я знаю, в вашей воле\nМеня презреньем наказать.\nНо вы, к моей несчастной доле\nХоть каплю жалости храня,\nВы не оставите меня.\nСначала я молчать хотела;\nПоверьте: моего стыда\nВы не узнали б никогда,\nКогда б надежду я имела\nХоть редко, хоть в неделю раз\nВ деревне нашей видеть вас,\nЧтоб только слышать ваши речи,\nВам слово молвить, и потом\nВсе думать, думать об одном\nИ день и ночь до новой встречи.\nНо, говорят, вы нелюдим;\nВ глуши, в деревне всё вам скучно,\nА мы… ничем мы не блестим,\nХоть вам и рады простодушно.\nЗачем вы посетили нас?\nВ глуши забытого селенья\nЯ никогда не знала б вас,\nНе знала б горького мученья.\nДуши неопытной волненья\nСмирив со временем (как знать?),\nПо сердцу я нашла бы друга,\nБыла бы верная супруга\nИ добродетельная мать.\nДругой!.. Нет, никому на свете\nНе отдала бы сердца я!\nТо в вышнем суждено совете…\nТо воля неба: я твоя;\nВся жизнь моя была залогом\nСвиданья верного с тобой;\nЯ знаю, ты мне послан богом,\nДо гроба ты хранитель мой…\nТы в сновиденьях мне являлся,\nНезримый, ты мне был уж мил,\nТвой чудный взгляд меня томил,\nВ душе твой голос раздавался\nДавно… нет, это был не сон!\nТы чуть вошел, я вмиг узнала,\nВся обомлела, запылала\nИ в мыслях молвила: вот он!\nНе правда ль? Я тебя слыхала:\nТы говорил со мной в тиши,\nКогда я бедным помогала\nИли молитвой услаждала\nТоску волнуемой души?\nИ в это самое мгновенье\nНе ты ли, милое виденье,\nВ прозрачной темноте мелькнул,\nПриникнул тихо к изголовью?\nНе ты ль, с отрадой и любовью,\nСлова надежды мне шепнул?\nКто ты, мой ангел ли хранитель,\nИли коварный искуситель:\nМои сомненья разреши.\nБыть может, это все пустое,\nОбман неопытной души!\nИ суждено совсем иное…\nНо так и быть! Судьбу мою\nОтныне я тебе вручаю,\nПеред тобою слезы лью,\nТвоей защиты умоляю…\nВообрази: я здесь одна,\nНикто меня не понимает,\nРассудок мой изнемогает,\nИ молча гибнуть я должна.\nЯ жду тебя: единым взором\nНадежды сердца оживи\nИль сон тяжелый перерви,\nУвы, заслуженным укором!\nКончаю! Страшно перечесть…\nСтыдом и страхом замираю…\nНо мне порукой ваша честь,\nИ смело ей себя вверяю…", complete:false)
    }
}
