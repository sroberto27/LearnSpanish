//
//  ContentView.swift
//  LearnSpanish
//
//  Created by roberto salazar on 11/27/21.
//
/*
 the name of the app
 LearnSpanish
 the author of the app
 Roberto Salazar
 in a single sentence, the intent or purpose of the app
 This purpose is to teach basic spanish phrases to english speakers and parctice correct pronunciation.
 a list of required techniques starting
 AUDIO player
 Speech recognition
 Custon fonts
 
 a description of what the app does and how it does it
 The APP has a total of 17 phrases in spanish. the user can read them in spanish and english. the user also can
 reproduce and audio with the spanish pronunciation. there is a button to start record or stop record. when the user
 starts record the user should try to pronunce the sentence in spanish once the user finish saying the sentence the user should
 press the button to stop record. depending on the pronunciation of the user the app will return a result of perfect, good ,or wrong.
 
 the app uses a json file to store strings of the sentences in spanish, and english. in the same json file I stored the link of the audio for the saentence. once the user starts voice recognition the divice stores the user pronunciation in a string once the user stops voice recognition the string is compared to the sentence in the json file using a levenshtein function to estimate identity and gives a result of perfect, good, or wrong.
 
 */

import SwiftUI
import Combine
import AVKit
import AVFoundation
import Foundation
import Speech

var counter = 0
var flag = false
struct Instances: Decodable, Hashable {
    var end: String!
    var ini: String!
    var english: String!
    var instance: String!
    var link: String!
}

struct Spacers: Decodable, Hashable {
    var instances: [Instances] = []
    var numPha: Int!
}
class SpacerService: ObservableObject {
 @Published var errorMessage: String = ""
 @Published var spacers: [Spacers] = []
 private var cancellableSet: Set<AnyCancellable> = []
 func getSpacers() {
     let spacersurl = URL(string:"https://api.jsonbin.io/b/61a2a0440ddbee6f8b12fd02/14")!
     
     URLSession.shared
         .dataTaskPublisher(for: URLRequest(url: spacersurl))
         .map(\.data)
         .decode(type: Spacers.self, decoder: JSONDecoder())
         .receive(on: RunLoop.main)
         .sink { completion in
             switch completion {
             case .finished:
                 break
             case .failure(let error):
                 self.errorMessage = error.localizedDescription
             }
         } receiveValue: {
             self.spacers.insert($0, at: 0)
         }.store(in: &cancellableSet)
 }
}

class SoundManager : ObservableObject {
    var audioPlayer: AVPlayer?

    func playSound(sound: String){
        if let url = URL(string: sound) {
            self.audioPlayer = AVPlayer(url: url)
        }
    }
}
//new font
extension Font {
static func bryndanWriteBook(size: CGFloat) -> Font {
             .custom("Bryndan-Write", size: size)
         }
}
func printFonts() {
   for familyName in UIFont.familyNames {
       print("\n-- \(familyName) \n")
       for fontName in UIFont.fontNames(forFamilyName: familyName) {
           print(fontName)
       }
   }
}
struct ContentView: View {
    private let speechRecognizer = SpeechRecognizer()
    @State var numberOfPhrases = 0
    @State var transcript = ""
    @State var spanish = "Presiona NEXT para empezar a aprender Español"
    @State var english = "Press NEXT to start learning Spanish"
    @State var colorRec = Color.blue
    @State var status = "Press to Start RECORDING"
    @State var audioPlayer: AVAudioPlayer!
    @State var soundFile = "adjourned.wav"
    @State var P = "Ready to learn some Spanish? Press NEXT"
    @State var L = ""
    @State var stat = " "
    @State var statColor = Color.white
    @State var result = 0
    @ObservedObject var spacerService = SpacerService()
    //func validation of pronuciation
    
    func validator(st1 : String , st2: String){
        result = st1.levenshtein(st2)
        if result == 0 {
            stat = "PERFECT"
            statColor = Color.green
        }else{
            if result >= 1 && result <= 3{
                stat = "GOOD"
                statColor = Color.yellow
            }else{
                if result >= 4{
                    stat = "TRY AGAIN"
                    statColor = Color.red
                }else{
                    stat = " "
                    statColor = Color.white
                }
            }
        }
    }
    
    // counter handeling
    func setCounter( value: Int){
        counter = value
    }
    func IncreaseCounter(){
        if counter < numberOfPhrases + 1 {
            counter += 1
        }else{
            counter = 0
        }
        
//        if counter == 11{
//            flag = true
//            counter = 0
//        }
    }
    func DecreaseCounter(){
        if counter>0 {
            counter -= 1
        }else{
            counter = 0
        }
    }
    func getCounter()-> Int{
        return counter
    }
    
    func manageFlag(){
        if flag{
            flag = false
        }else{
            flag = true
        }
    }
    
    func setFlag( value : Bool){
        flag = value
    }
    
    func getFlag()-> Bool{
        return flag
    }
    
    
    var body: some View {
        NavigationView {
            
            VStack {
                
                List {
                    Text("Learn Spanish!")
                        .font(.bryndanWriteBook(size: 30))
                    ForEach(spacerService.spacers, id: \.self) { spacer in
                        
                     //   Text("somethin 1")
                        //Text("Learn Spanish!").font(.title).padding()
                        
                           // Text(spacer.questions[counter].question).padding(55)
                        VStack{
                            Text("Spanish : ")
                            Text(spanish).font(.title3)
                                .foregroundColor(.red)
                                .padding()
                            Text("English : ")
                            Text(english).font(.title3)
                                .foregroundColor(.blue)
                                .padding()
                        }
                        VStack{
                            Text("Your pronunciation")
                            Text(transcript)
                        }
                        
                        if counter == 0{
                            VStack{
                            Button(" Next ") {
                                numberOfPhrases = spacer.numPha
                                print("0gggkkdjgkjkjfkjdkjfk")
                                print(numberOfPhrases)
                                //printFonts()
                                IncreaseCounter()
                                spanish =  spacer.instances[counter].instance + spacer.instances[counter].end
                                english = spacer.instances[counter].english + spacer.instances[counter].end
                                P = spacer.instances[counter].instance
                                L = spacer.instances[counter].link
                              //  print(spacer.instances[counter].instance)
                              //  print(spacer.instances[counter].link)
                                
                               // print(counter)
                            }.font(.title3)
                                    .buttonStyle(.bordered)
                            
                            }
                            
                            
                        }else{
                            if counter == numberOfPhrases+1 {
                                VStack{
                                Button(" Next ") {
                                    statColor = Color.white
                                    stat = " "
                                    setCounter(value: 0)
                                    spanish = spacer.instances[counter].instance
                                    english = spacer.instances[counter].english
                                    P = spacer.instances[counter].instance
                                    L = spacer.instances[counter].link
                                //    print(spacer.instances[counter].instance)
                                  //  print(spacer.instances[counter].link)
                                    
                                    //print(counter)
                                }.font(.title3)
                                    .buttonStyle(.bordered)
                                }
                                
                            }else{
                                
                                VStack {
                                    Text("Spanish pronunciation")
                                    VideoPlayer(player: AVPlayer(
                                        url:  URL(string: spacer.instances[counter].link!)!))
                                        .frame(height: 50)
                                }
                                VStack(alignment: .center){
                                    Text(stat)
                                        .background(statColor)
                                Button(status) {
                                    if getFlag() {
                                        //print("--------------------------------------------------------------")
                                        //call here the audio text verification
                                        validator(st1: transcript, st2: spacer.instances[counter].instance)
                                       // print(transcript.levenshtein(spacer.instances[counter].instance))
                                        status = "Press to Start RECORDING"
                                        colorRec = Color.blue
                                        setFlag(value: false)
                                        speechRecognizer.stopRecording()
                                    }else{
                                        status = "Press to Stop RECORDING"
                                        colorRec = Color.red
                                        setFlag(value: true)
                                        speechRecognizer.record(to: $transcript)
                                    }
                                }.font(.title3)
                                    .padding(30)
                                    .background(colorRec)
                                
                                
                                Button(" Next ") {
                                    statColor = Color.white
                                    stat = " "
                                    IncreaseCounter()
                                    transcript = ""
                                    spanish =  spacer.instances[counter].instance + spacer.instances[counter].end
                                    english = spacer.instances[counter].english + spacer.instances[counter].end
                                    P = spacer.instances[counter].instance
                                    L = spacer.instances[counter].link
                                  //  print(spacer.instances[counter].instance)
                                   // print(spacer.instances[counter].link)
                                    
                                   // print(counter)
                                }.font(.title3)
                                    .buttonStyle(.bordered)
                                }
                                
                            }
                        }
                        
                        
                        
                        
                    }
                    if spacerService.errorMessage.count == 0 {
                        Text("\(spacerService.errorMessage)")
                    }
                    
                    
                }
                
            }
        }.onAppear(perform: {spacerService.getSpacers()})
    }
}

extension String {
    subscript(index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
}

extension String {
    public func levenshtein(_ other: String) -> Int {
        let sCount = self.count
        let oCount = other.count

        guard sCount != 0 else {
            return oCount
        }

        guard oCount != 0 else {
            return sCount
        }

        let line : [Int]  = Array(repeating: 0, count: oCount + 1)
        var mat : [[Int]] = Array(repeating: line, count: sCount + 1)

        for i in 0...sCount {
            mat[i][0] = i
        }

        for j in 0...oCount {
            mat[0][j] = j
        }

        for j in 1...oCount {
            for i in 1...sCount {
                if self[i - 1] == other[j - 1] {
                    mat[i][j] = mat[i - 1][j - 1]       // no operation
                }
                else {
                    let del = mat[i - 1][j] + 1         // deletion
                    let ins = mat[i][j - 1] + 1         // insertion
                    let sub = mat[i - 1][j - 1] + 1     // substitution
                    mat[i][j] = min(min(del, ins), sub)
                }
            }
        }

        return mat[sCount][oCount]
    }
}




struct SpeechRecognizer {
    private class SpeechAssist {
        var audioEngine: AVAudioEngine?
        var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
        var recognitionTask: SFSpeechRecognitionTask?
        let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "es-VE"))

        deinit {
            reset()
        }

        func reset() {
            recognitionTask?.cancel()
            audioEngine?.stop()
            audioEngine = nil
            recognitionRequest = nil
            recognitionTask = nil
        }
    }

    private let assistant = SpeechAssist()

    func record(to speech: Binding<String>) {
        relay(speech, message: "Requesting access")
        canAccess { authorized in
            guard authorized else {
                relay(speech, message: "Access denied")
                return
            }

            relay(speech, message: "Access granted")

            assistant.audioEngine = AVAudioEngine()
            guard let audioEngine = assistant.audioEngine else {
                fatalError("Unable to create audio engine")
            }
            assistant.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = assistant.recognitionRequest else {
                fatalError("Unable to create request")
            }
            recognitionRequest.shouldReportPartialResults = true

            do {
                relay(speech, message: "Booting audio subsystem")

                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                let inputNode = audioEngine.inputNode
                relay(speech, message: "Found input node")

                let recordingFormat = inputNode.outputFormat(forBus: 0)
                inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                    recognitionRequest.append(buffer)
                }
                relay(speech, message: "Preparing audio engine")
                audioEngine.prepare()
                try audioEngine.start()
                assistant.recognitionTask = assistant.speechRecognizer?.recognitionTask(with: recognitionRequest) { (result, error) in
                    var isFinal = false
                    if let result = result {
                        relay(speech, message: result.bestTranscription.formattedString)
                        isFinal = result.isFinal
                    }

                    if error != nil || isFinal {
                        audioEngine.stop()
                        inputNode.removeTap(onBus: 0)
                        self.assistant.recognitionRequest = nil
                    }
                }
            } catch {
                print("Error transcibing audio: " + error.localizedDescription)
                assistant.reset()
            }
        }
    }
    func stopRecording() {
        assistant.reset()
    }
    private func canAccess(withHandler handler: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            if status == .authorized {
                AVAudioSession.sharedInstance().requestRecordPermission { authorized in
                    handler(authorized)
                }
            } else {
                handler(false)
            }
        }
    }
    private func relay(_ binding: Binding<String>, message: String) {
        DispatchQueue.main.async {
            binding.wrappedValue = message
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
