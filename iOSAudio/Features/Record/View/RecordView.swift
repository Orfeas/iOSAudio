//
//  ContentView.swift
//  iOS Audio
//
//  Created by Orfeas Iliopoulos on 27/2/21.
//

import SwiftUI
import googleapis

struct RecordView: View {
    
    @ObservedObject var viewModel = RecordViewModel()
    
    var buttonHeight = CGFloat(50.0)
    
    @State var speechText = "Your recording will show here"
    @State var recordButtonTapped = false
    @State var playButtonTapped = false
    @State var errorMessage = ""
    @State var useAppleService = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(alignment: .center, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                    Text("1. Record, 2. View transcribed text, 3. Play back audio with text highlighting.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 40.0)
                    
                    // If we stopped recording and we have some transcribed text show that. Otherwise we are starting a new recording and we need to show
                    // the placeholder text again
                    HighlightedString(text: viewModel.transcription.transcribedText ?? "", range: viewModel.transcription.playbackWordRange ?? NSRange())
                        .frame(minWidth: 100,
                               idealWidth: .infinity,
                               maxWidth: .infinity,
                               minHeight: 0,
                               idealHeight: geometry.size.height / 3,
                               maxHeight: geometry.size.height / 3,
                               alignment: .top)
                        .padding()
                    
                    // Google's API doesn't return the timepoints so you can use Apple's speech synthesizer to view the highligted text
                    Toggle(isOn: $useAppleService, label: { Text("Use Apple's Speech Synthesizer to higlight text as it is played back to you") })
                        .padding()
                    
                    Spacer()
                    
                    HStack(alignment: .center, spacing: nil, content: {
                        Spacer()
                        
                        GeometryReader { btnGeometry in
                            Button(action: {                                
                                
                                // If pressed record button start recording otherwise stop
                                _ = viewModel.transcription.didFinishTranscribing ? viewModel.startRecording() : viewModel.stopRecording()
                                
                                viewModel.transcription.didFinishTranscribing.toggle()
                            }) {
                                Text(viewModel.transcription.didFinishTranscribing ? "Record" : "Stop recording")
                                    .frame(width: btnGeometry.size.width, height: btnGeometry.size.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                    .foregroundColor(.white)
                            }
                        }
                        .modifier(ActionButtonModifier(disable: !viewModel.transcription.didFinishPlayback))
                        
                        Spacer()
                        
                        GeometryReader { btnGeometry in
                            Button(action: {
                                
                                let boolInt = useAppleService ? 1 : 0

                                // If pressed the play button start speaking the text otherwise stop
                                _ = viewModel.transcription.didFinishPlayback ? viewModel.startSpeakingTextWithPlaybackType(PlaybackType(rawValue: boolInt) ?? .google) : viewModel.stopSpeakingText()
                                
                                viewModel.transcription.didFinishPlayback.toggle()
                                
                            }) {
                                Text(viewModel.transcription.didFinishPlayback ? "Play" : "Stop")
                                    .frame(width: btnGeometry.size.width, height: btnGeometry.size.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                    .foregroundColor(.white)
                                    .disabled(viewModel.transcription.transcribedText == nil)
                                    .opacity(viewModel.transcription.transcribedText == nil ? 0.3 : 1.0)
                            }
                        }
                        .modifier(ActionButtonModifier(disable: !viewModel.transcription.didFinishTranscribing))
                        
                        Spacer()
                        
                    })
                })
                .alert(isPresented: $viewModel.transcription.didFinishWithError) {
                    var errorDescription = "Something went wrong with recording. Please try recording again."
                    
                    if let trascribedErrorDescription = viewModel.transcription.trascribedError?.localizedDescription {
                        errorDescription = trascribedErrorDescription
                    }
                    
                    return Alert(title: Text("Important message"), message: Text(errorDescription), dismissButton: .default(Text("OK")))
                }
                .alert(isPresented: $viewModel.transcription.didFailToPlayback, content: {
                    var errorDescription = "Something went wrong with playing back your text."
                    
                    if let trascribedErrorDescription = viewModel.transcription.trascribedError?.localizedDescription {
                        errorDescription = trascribedErrorDescription
                    }
                    
                    return Alert(title: Text("Important message"), message: Text(errorDescription), dismissButton: .default(Text("OK")))
                })
            }
            .navigationBarTitle(Text("iOS ❤️ Audio"), displayMode: .inline)
            .toolbar {
                Button("Clear") {
                    viewModel.transcription.transcribedText = nil
                    viewModel.stopRecording()
                }
                // Enable/Disable the button if we have or not transcribed any text
                .disabled(viewModel.transcription.transcribedText == nil)
            }
        }
        
    }
    
}

#if DEBUG
struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView().previewDevice("iPhone 12 Pro Max")
    }
}
#endif
