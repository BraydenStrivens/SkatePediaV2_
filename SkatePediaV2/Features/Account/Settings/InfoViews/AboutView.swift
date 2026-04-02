//
//  AboutView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import SwiftUI
import Foundation

struct AboutView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) private var openURL
    
    private let aboutMe: String = """
        I'm a computer science major who has been skateboarding for over ten years and learned 90 out of the 100 tricks provided in this app. The idea behind this app is based off of my own process for learning new tricks. This involves trying a trick, recording my attempts, comparing it to professional skateboarders, figuring out what to improve on based on the comparison, and focusing on those insights the next time I try the trick. I am very much still an inexperienced programmer so if you run into problems while using this app or have ideas to make it better, please feel free to contact me with the two methods listed below. Thank you for downloading this app and I hope it helps you learn new tricks!
        """
    
    private let aboutSkatePedia: String = """
        SkatePedia is a project for one of my college classes. Because of this, I can't guarantee this app will stay up for very long after I graduate. However, if it gets a decent number of users who find it useful I will continue working on this app in my free time. This being said, I would like to explain the various features of SkatePedia.
        """
    
    private let trickListExplanation: String = """
        I decided to use a standardized list of the 25 most basic combinations of tricks from beginner to advanced. Users can add new tricks they wish to learn however pro videos will not be available for them. Each of the 25 tricks can be displayed using their technical name or an abbreviated version which is changeable in the settings. Because there is no committee overseeing the skateboarding community, the naming of tricks can differ from person to person. I would like to avoid confusion over my choice of trick names. Regular and Switch tricks dont have any contradictions in their names however Fakie and Nollie do. It seems that a Frontside Flip done fakie is a Fakie Frontside Flip, however a switch Frontside Flip done Nollie is called a Nollie Backside Flip. So frontside and backside switch for Fakie and Nollie tricks and I have named all the Nollie tricks according to this rule.
        """
    
    private let trickItemExplanation: String = """
        The foundation of this app is Trick Items. Users can use Trick Items to analyze their skateboarding. Trick Items contain a rating from 0-3 of your progress on a trick, notes to keep in mind when trying the trick, and video of the trick attempt to analyze. A Trick Item's videos can be compared with other Trick Items of the same trick or video of professional skateboardings doing the same trick if available.
        """
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                aboutViewSection(header: "About Me") {
                    VStack {
                        Text(aboutMe)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Email:")
                                Text("Instagram:")

                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                let email = "skatepediaiosapp@gmail.com"
                                Button(email) {
                                    if let url = URL(string: "mailto:\(email)"),
                                       UIApplication.shared.canOpenURL(url) {
                                        openURL(url)
                                    } else {
                                        print("Mail app not available")
                                    }
                                }
                                
                                let instaUsername = "b_bizzlemonizzle"
                                Button(instaUsername) {
                                    openInstagram(username: instaUsername)
                                }
                            }
                            .foregroundColor(Color.textAccent)
                        }
                        .padding(.top, 6)
                    }
                }
                
                aboutViewSection(header: "About SkatePedia") {
                    VStack(alignment: .leading) {
                        Text(aboutSkatePedia)
                    }
                }
                
                aboutViewSection(header: "Trick List") {
                    VStack(alignment: .leading) {
                        Text(trickListExplanation)
                    }
                }
                
                aboutViewSection(header: "Trick Items") {
                    VStack(alignment: .leading) {
                        Text(trickItemExplanation)
                    }
                }
            }
            .padding(12)
        }
    }
    
    func aboutViewSection<Content: View>(
        header: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading) {
            Text(header)
                .font(.caption)
                .foregroundStyle(.gray)
            
            content()
                .padding()
                .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).protruded)
        }
    }
    
    private func openInstagram(username: String) {
        let appURL = URL(string: "instagram://user?username=\(username)")!
        let webURL = URL(string: "https://instagram.com/\(username)")!
        
        if UIApplication.shared.canOpenURL(appURL) {
            openURL(appURL)
        } else {
            openURL(webURL)
        }
    }
}

