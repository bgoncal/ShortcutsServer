//
//  ContentView.swift
//  ShortcutsServer
//
//  Created by Bruno Pantaleão on 18/05/2023.
//

import SwiftUI
import Swifter
import UIKit

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State var operating: String = "false"

    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 16) {
            Text("Shortcuts Server")
                .font(.largeTitle.bold())
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            HStack {
                Text("Operating:")
                Text(operating)
                    .font(.headline.bold())
                    .foregroundColor(operating == "true" ? .green : .red)
            }
        }
        .padding()
        .onAppear {
            viewModel.onAppear()
        }
        .onReceive(timer) { _ in
            operating = viewModel.operating()
        }
    }
}

class ContentViewModel: ObservableObject {

    @Published var server = HttpServer()

    func onAppear() {
        guard !server.operating else { return }
        server["/shortcut"] = { request in
            let input = request.queryParams.first(where: { $0.0 == "input" })?.1 ?? ""
            if let shortcutName = request.queryParams.first(where: { $0.0 == "name" })?.1,
               let encodedString = "shortcuts://run-shortcut?name=\(shortcutName)&input=text&text=\(input)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: encodedString) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }
            }
            return .accepted
        }
        try! server.start()
    }

    func operating() -> String {
        "\(server.operating)"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
