//
//  ContentView.swift
//  CleverTap
//
//  Created by huyoi on 18/4/26.
//

import SwiftUI
import CleverTapSDK

struct ContentView: View {
    var body: some View {
        TabView {
            VStack(spacing: 20) {

                Text("Welcome!")

                Button("Track Product Viewed") {

                    CleverTap.sharedInstance()?.recordEvent(
                        "Product Viewed",
                        withProps: [
                            "Product ID": 1,
                            "Product Image": "https://d3girlcugktkx3.cloudfront.net/1667829376/assets/f3c59b42dce442ee946a8ce867f0a403.jpeg",
                            "Product Name": "CleverTap"
                        ]
                    )

                    CleverTap.sharedInstance()?.profilePush([
                        "Email": "clevertap+tnyh02@gmail.com"
                    ])

                    print("DEVLOG: Event + Profile pushed")
                }

            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
        }
    }
}

#Preview {
    ContentView()
}
