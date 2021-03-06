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
struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
struct CameraAndTextView: View{
    @State private var orientation = UIDeviceOrientation.unknown
    
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
    @State var modes = ["Share", "Video"]
    @State var currentMode = "Share"
    var body: some View {
        
        VStack{
            Picker(selection: $currentMode, label: Text("Mode")) {
                ForEach(modes, id: \.self) {
                    Text(LocalizedStringKey($0))
                        
                    
                }
                
            }
            .pickerStyle(.segmented)
            .padding()
            Spacer()
         HStack{
             Button(action: {
                 if paragraphStep > 0{
                     paragraphStep -= 1
                 }


             }, label: {
                
                     
                     Image(systemName: "chevron.compact.left")
                         .foregroundColor(Color.primary)
                         .imageScale(.large)
                
             })
                 .buttonStyle(BorderlessButtonStyle())
                 .accessibility(label: Text("???????????? ?????? ??????????????????????????"))
                 .padding()
             Spacer()
             Text(fourLines[paragraphStep])
                 .font(fontName == "System" ? .system(size: 18, design: .serif):.custom(fontName, size: 18))
                 .padding()
                 .foregroundColor(Color.primary)
                 .textSelection(.enabled)
                 .onDrag{
                     return NSItemProvider(object: NSString(string: fourLines[paragraphStep]))
                 }
                 .onChange(of: inputText, perform: { value in
                     fourLineParse()
                 })
             
                 .onAppear{
                     fourLineParse()
                     
                 }
                 .frame(height: 250)
             Spacer()
             Button(action: {

                 if paragraphStep < fourLines.count-1{
                     paragraphStep += 1
                    
                 }

             }, label: {
                
                     Image(systemName: "chevron.compact.right")
                         .foregroundColor(Color.primary)
                         .imageScale(.large)
                     
                 
             })
             
                 .buttonStyle(BorderlessButtonStyle())
                 .accessibility(label: Text("?????????????????? ??????????????????????????"))
                 .padding()
         }
            Spacer()
            switch currentMode{
            case "Share":
                Text("")
            case "Video":
                
                ZStack {
                    CameraView()
                        .cornerRadius(13.0)
                        .padding()
                    
                if orientation.isLandscape{
                        Rectangle()
                            .cornerRadius(13.0)
                            .padding()
                            .background(.thickMaterial)
                        Label("Please rotate your device vertically", systemImage: "arrow.turn.up.forward.iphone")
                            
                    
                   
                }
            }
            default:
                Text("")
            }
           
               
           
           
               
        
            
        }
        .animation(.spring(), value: currentMode)
        .frame(minWidth: 300, minHeight: 500)
        .onRotate { newOrientation in
                   orientation = newOrientation
               }
        .onAppear(){
            orientation = UIDevice.current.orientation
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
