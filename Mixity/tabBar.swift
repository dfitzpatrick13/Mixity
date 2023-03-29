//
//  tabBar.swift
//  Mixity
//
//  Created by Daniel Fitzpatrick on 3/28/23.
//

import SwiftUI

struct tabBar:  View { 
    var body:  some View {
        
        TabView {
            Homeview()
                .tabItem{
                    Label("Search", systemImage:"map.circle")
                }
            profileView()
                .tabItem{
                    Label("Profile", systemImage:"person.crop.circle.fill")
                }
            searchView()
                .tabItem{
                    Label("Information", systemImage:"book.closed.circle")
                }
        }
        
        
    }
}

  

struct tabBar_Previews: PreviewProvider {
    static var previews: some View {
        tabBar()
    }
}
