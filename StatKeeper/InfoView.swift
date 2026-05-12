//
//  InfoView.swift
//  StatKeeper
//
//  Copyright © 2026 Kenny Gruchalla
//  Licensed under the MIT License. See LICENSE in the project root for license information.
//

import SwiftUI

/// An "About" screen shown modally from PlayerView.
/// Presents app name/version, links to GitHub/issues, and an embedded privacy policy summary.
struct InfoView: View {
    var body: some View {
        // Use a NavigationStack so we can set a title and get standard nav behavior when presented.
        NavigationStack {
            // Scroll to support long policy text on smaller devices.
            ScrollView {
                VStack(spacing: 8) {
                    Text("StatKeeper")
                        .font(.title2).bold()
                    Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    Text("""
                        **StatKeeper** is a free SwiftUI iPhone app for tracking a single basketball player's in-game performance. Designed for parents, StatKeeper makes it easy to record key stats in real time and maintain a history of performance across games. StatKeeper is open-sourced under the MIT license and available on [GitHub](https://github.com/gruchalla/StatKeeper). 
                        """)
                    
                    // Issue tracker link
                    Text("""
                        Found a bug or have a suggestion? [Open an issue on GitHub](https://github.com/gruchalla/StatKeeper/issues)
                        """)
                    .font(.footnote)

                    Divider()
                    
                    // Privacy policy section with optional external link and embedded summary.
                    VStack(alignment: .leading, spacing: 8) {
                        // Replace with your actual Privacy Policy URL or an embedded view.
                        if let url = URL(string: "https://github.com/gruchalla/StatKeeper/blob/main/PrivacyPolicy.md") {
                            Link("Privacy Policy", destination: url)
                        }
                        
                        Text("""
                        **Overview** 
                        The StatKeeper App is provided at no cost and is intended for use as is. This policy informs you of our policies regarding the collection, use, and disclosure of Personal Information.
                        
                        **Information Collection and Use** 
                        We do not collect, store, or share any personal data from our users. 
                        • Local Storage Only: All data created by the user, including counts and notes, is stored on the user’s own device using Apple's SwiftData framework.
                        • No Remote Access: We do not have access to your data. It is not transmitted to any external servers or third parties.
                        
                        **Data Security** 
                        Since all data is stored locally, its security is protected by the built-in security features of your iPhone. We recommend keeping your device updated and using a passcode or biometric authentication to protect your data.
                        
                        **Third-Party Services** 
                        The app does not use any third-party services (such as analytics, advertising, or cloud hosting) that may collect information used to identify you.
                        
                        **User Rights (GDPR & CCPA)** 
                        Since we do not collect or process your data, we do not have the ability to "delete" or "provide" your data upon request. You maintain full control over your data:
                        • Access/Portability: You can view all your data within the app interface.
                        • Erasure: You can delete your data at any time by removing individual entries within the app or by uninstalling the app, which will remove all associated SwiftData files from your device.
                        
                        **Changes to This Privacy Policy** 
                        We may update our Privacy Policy from time to time. You are advised to review this page periodically for any changes. These changes are effective immediately after they are posted on this page.
                        
                        **Contact Us** If you have any questions or suggestions about our Privacy Policy, contact us at: gruchalla@gmail.com.
                        """)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading) // Left-align long text in the scroll view
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("About")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
