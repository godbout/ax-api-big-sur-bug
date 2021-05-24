import SwiftUI

struct TextView: NSViewRepresentable {

    @Binding var text: String
    typealias NSViewType = NSTextView

    func makeNSView(context: Context) -> NSTextView {
        NSTextView()
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        nsView.string = text
    }

}

struct ContentView: View {

    @State var textFieldValue = ""
    @State var textViewValue = "this is some\ntext\nthat looks\nbeautiful"

    var body: some View {
        VStack {
            TextField("single line text field for test", text: $textFieldValue)

            if #available(macOS 11.0, *) {
                TextEditor(text: $textViewValue)
            } else {
                TextView(text: $textViewValue)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
            }

            Button("get", action: {
                if let axFocusedElement = AXEngine.axFocusedElement() {
                    var values: CFArray?
                    let error = AXUIElementCopyMultipleAttributeValues(axFocusedElement, [kAXValueAttribute, kAXSelectedTextRangeAttribute] as CFArray, .stopOnError, &values)

                    if error == .success, let values = values as NSArray? {
                        var selectedTextRange = CFRange()
                        AXValueGetValue(values[1] as! AXValue, .cfRange, &selectedTextRange)

                        let axCaretLocation = selectedTextRange.location
                        var axLineStart: Int?
                        var axLineEnd: Int?

                        if let axLineNumber = AXEngine.axLineNumberFor(location: axCaretLocation, on: axFocusedElement) {
                            let axLineRange = AXEngine.axLineRangeFor(lineNumber: axLineNumber, on: axFocusedElement)

                            axLineStart = axLineRange!.location
                            axLineEnd = axLineStart! + axLineRange!.length
                        }

                        print("line start: \(String(describing: axLineStart)), line end: \(String(describing: axLineEnd))")
                    }
                }
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()

            Button("set", action: {
                if let axFocusedElement = AXEngine.axFocusedElement() {
                    var selectedTextRange = CFRange()
                    selectedTextRange.location = 13
                    selectedTextRange.length = 1

                    let newValue = AXValueCreate(.cfRange, &selectedTextRange)

                    AXUIElementSetAttributeValue(axFocusedElement, kAXSelectedTextRangeAttribute as CFString, newValue!)                    
                }
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
