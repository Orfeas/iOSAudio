//
//  TextWithAttributedString.swift
//  iOSAudio
//
//  Created by Orfeas Iliopoulos on 28/2/21.
//

import SwiftUI

struct TextWithAttributedString: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    var attributedString: NSMutableAttributedString
    
    func makeUIView(context: Context) -> UITextView {
        let label = UITextView()
        label.layer.borderWidth = 1.0
        label.layer.borderColor = UIColor.gray.cgColor
        label.autoresizesSubviews = true
        label.backgroundColor = UIColor.systemBackground
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return label
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedString
    }
}

struct AttributedTextModel {
    @Environment(\.colorScheme) var colorScheme

    func highlightString(text: String, inRange range: NSRange) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black], range: NSRange(location: 0, length: text.count))
        attributedString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.blue], range: range)
        attributedString.addAttributes([NSAttributedString.Key.backgroundColor : UIColor.systemTeal], range: range)

        return attributedString

    }
}

struct HighlightedString: View {
    var text: String
    var range: NSRange
    var customAttributedModel = AttributedTextModel()
    
    var body: some View {
        TextWithAttributedString(attributedString: customAttributedModel.highlightString(text: text, inRange: range))
    }
}
