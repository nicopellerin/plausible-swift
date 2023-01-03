//
//  ContentView.swift
//  Plausible Lite Swift
//
//  Created by Nicolas Pellerin on 2023-01-02.
//

import SwiftUI

struct Visitors: Codable {
    let value: Int
}

struct Pageviews: Codable {
    let value: Int
}

struct Stats: Codable {
    let visitors: Visitors
    let pageviews: Pageviews
}

struct Results: Codable {
    let results: Stats
}

struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.vertical, 8)
            .padding(.horizontal, 24)
            .background(
                Color("Background")
            )
            .clipShape(Capsule(style: .continuous))
    }
}


struct PrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color("PrimaryColor"))
            .foregroundColor(.white)
            .cornerRadius(4)
            .fontWeight(.semibold)
            .font(.title3)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

class Api {
    func getStats(pData: Data, completion: @escaping (Results) -> ()) {
        let siteId: String = pData.siteId
        
        print("PODATA", pData)
        
        let url = URL(string: "https://plausible.io/api/v1/stats/aggregate?site_id=\(siteId)&period=day&metrics=visitors,pageviews")!
        
        let token = pData.apiKey
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { (data, _, _) in
            let res = try! JSONDecoder().decode(Results.self, from: data!)
            
            print("RES", res)
            
            DispatchQueue.main.async {
                completion(res)
            }
        }.resume()
    }
}

struct ContentView: View {
    @Binding var isLoggedIn: Bool
    @Binding var pData: Data

    var body: some View {
    
        VStack {
            if !isLoggedIn {
                LoginView(isLoggedIn: $isLoggedIn)
            } else {
                AppView(isLoggedIn: $isLoggedIn, pData: $pData)
            }
        }

    }
}

struct LoginView: View {
    @State var siteId: String = ""
    @State var apiKey: String = ""
    
    @Binding var isLoggedIn: Bool


    var body: some View {
        ZStack {
            Color("Background")
            LinearGradient(colors: [Color("PrimaryColor"), Color("SecondaryColor")],
                           startPoint: .topLeading,
                           endPoint: .center).opacity(0.15)
            
            VStack {
                Form {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Site ID (Domain)").fontWeight(.medium).foregroundColor(Color("LabelColor"))
                            TextField("", text: $siteId)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 12)
                                .textFieldStyle(.plain)
                                .foregroundColor(Color("TextColor"))
                                .background(Color("InputBackground"))
                                .overlay( RoundedRectangle(cornerRadius: 4) .stroke(Color("InputBorder"), lineWidth: 3) )
                                .cornerRadius(4)
                                .font(.system(size: 16))
                                .accentColor(Color.black)
                                .frame(height: 46)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("API Key").fontWeight(.medium).foregroundColor(Color("LabelColor"))
                            SecureField("", text: $apiKey)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 12)
                                .textFieldStyle(.plain)
                                .foregroundColor(Color("TextColor"))
                                .background(Color("InputBackground"))
                                .overlay( RoundedRectangle(cornerRadius: 4) .stroke(Color("InputBorder"), lineWidth: 3) )
                                .cornerRadius(4)
                                .font(.system(size: 16))
                                .accentColor(Color.black)
                                .frame(height: 46)
                        }
                        
                        let pData = Data(apiKey: apiKey, siteId: siteId)
                        
                            Button("Save") {
                                print("Button pressed!")
                                
                                AppStore.save(pData: pData) { _ in
                                    print("Save")
                                }
                                
                                Api().getStats(pData: pData) { (stats) in
                                    print("STATS", stats)
                                    isLoggedIn = true
                                }
                                
                            }
                            .buttonStyle(PrimaryButton())
                    }
                }
            }.padding(40)
        }.frame(width: 400, height: 320)
    }
}



struct AppView: View {
    @State var visitors: Int = 0
    @State var pageviews: Int = 0

    @Binding var isLoggedIn: Bool
    @Binding var pData: Data
    
    var body: some View {
        ZStack {
            Color("Background")
            LinearGradient(colors: [Color("PrimaryColor"), Color("SecondaryColor")],
                           startPoint: .topLeading,
                           endPoint: .center).opacity(0.15)
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    HStack(spacing: 12) {
                        Text("nicopellerin.io")
                            .font(.system(size: 16))
                            .bold()
                        HStack(spacing: 6) {
                            Circle().fill(Color.green).frame(width: 8, height: 8)
                            Text("0")
                                .foregroundColor(Color("LabelColor"))
                                .bold()
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            Api().getStats(pData: pData) { (stats) in
                                print("Refresh", stats)
                                self.visitors = stats.results.visitors.value
                                self.pageviews = stats.results.pageviews.value
                            }
                        },
                               label: {
                            Image("Refresh")
                        }
                        ).buttonStyle(.plain)
                        
                        Button(action: {
                            AppStore.delete() { _ in
                                print("Save")
                                isLoggedIn = false
                            }
                        },
                               label: {
                            Image("Settings")
                        }
                        ).buttonStyle(.plain)
                    }
                   
                }
                
                HStack {
                    VStack(spacing: 4) {
                        Text("Unique visitors".uppercased())
                            .font(.system(size: 12))
                            .kerning(0.8)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("LabelColor"))
                        Text("\(visitors)")
                            .font(.system(size: 32))
                            .fontWeight(.bold)
                            .foregroundColor(Color("TextColor"))
                    }
                    
                    Spacer()
                    Rectangle().fill(Color("InputBorder")).frame(width: 2, height: 50).padding(.horizontal, 12).offset(x: -16)
                    
                    VStack(spacing: 4) {
                        Text("Page Views".uppercased())
                            .font(.system(size: 12))
                            .kerning(0.8)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("LabelColor"))
                        Text("\(pageviews)")
                            .font(.system(size: 32))
                            .fontWeight(.bold)
                            .foregroundColor(Color("TextColor"))
                    }
                }.padding(30).background(Color("InputBackground")).overlay( RoundedRectangle(cornerRadius: 4) .stroke(Color("InputBorder"), lineWidth: 1))
            }.frame(width: 340)
            
        }
        .onAppear {
            if !pData.apiKey.isEmpty && !pData.siteId.isEmpty {
                Api().getStats(pData: pData) { (stats) in
                    print("STATS", stats)
                    self.visitors = stats.results.visitors.value
                    self.pageviews = stats.results.pageviews.value
                }
            }
        }
        .frame(width: 400, height: 235)
    }
}


//struct ContentView_Previews: PreviewProvider {
//    @StateObject public var store = AppStore()
//
//    static var previews: some View {
//        ContentView(store: store)
//    }
//}
