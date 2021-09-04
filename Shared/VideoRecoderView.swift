//
//  VideoRecoderView.swift
//  VideoRecoderView
//
//  Created by Tema Sysoev on 04.09.2021.
//

import SwiftUI
import UIKit
import AVKit
import MobileCoreServices
import AVFoundation
struct CameraView: UIViewControllerRepresentable {

    // 2.
    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController()
    }
    
    // 3.
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        
    }
}
struct CameraAndTextView: View{
    @State var language: String
    @State var author: String
    @State var title: String
    @State var inputText: String
    @State var selectedIndex = Int()
    @State var fontName: String
    @State var fourLines = ["""
    """]
    @State var paragraphStep = 0
    @State var fourLinesForWordsParse = [String]()
    var body: some View {
        VStack{
            CameraView()
                .padding()
                .clipShape(RoundedRectangle(cornerRadius: 13.0))
            Text(fourLines[paragraphStep])
                .font(fontName == "System" ? .system(size: 18, design: .serif):.custom(fontName, size: 18))
            
                .foregroundColor(Color.primary)
                .onChange(of: inputText, perform: { value in
                    fourLineParse()
                })
                .onAppear{
                    fourLineParse()
                    
                }
            HStack{
                Button(action: {
                    if paragraphStep > 0{
                        paragraphStep -= 1
                    }


                }, label: {
                    ZStack{
                        
                        Circle()
                        
                            .foregroundColor(Color.red.opacity(0.3))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "arrow.left")
                            .foregroundColor(Color.red)
                            .imageScale(.large)
                        
                        
                    }
                })
                    .buttonStyle(BorderlessButtonStyle())
                    .accessibility(label: Text("Заново это четверостишие"))
                
                Button(action: {

                    if paragraphStep < fourLines.count-1{
                        paragraphStep += 1
                       
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
}
