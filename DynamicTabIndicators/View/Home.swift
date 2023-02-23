//
//  Home.swift
//  DynamicTabIndicators
//
//  Created by COBY_PRO on 2023/02/24.
//

import SwiftUI

struct Home: View {
    /// View Properties
    @State private var currentTab: Tab = tabs_[0]
    @State private var tabs: [Tab] = tabs_
    @State private var contentOffset: CGFloat = 0
    @State private var indicaterWidth: CGFloat = 0
    @State private var indicaterPosition : CGFloat = 0
    var body: some View {
        TabView(selection: $currentTab) {
            ForEach(tabs) { tab in
                GeometryReader {
                    let size = $0.size
                    
                    Image(tab.title)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height)
                }
                .clipped()
                .ignoresSafeArea()
                .offsetX { rect in
                    if currentTab.title == tab.title {
                        contentOffset = rect.minX - (rect.width * CGFloat(index(of: tab)))
                    }
                    
                    updateTabFrame(rect.width)
                }
                .tag(tab)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
        .overlay(alignment: .top, content: {
            TabsView()
        })
        .preferredColorScheme(.dark)
    }
    
    /// Calculating Tab Width & Position
    func updateTabFrame(_ tabViewWidth: CGFloat) {
        let inputRange = tabs.indices.compactMap { index -> CGFloat? in
            return CGFloat(index) * tabViewWidth
        }
        
        let outputRangeForWidth = tabs.compactMap { tab -> CGFloat? in
            return tab.width
        }
        
        let outputRangeForPosition = tabs.compactMap { tab -> CGFloat? in
            return tab.minX
        }
        
        let widthInterpolation = LineInterpolation(inputRange: inputRange, outputRange: outputRangeForWidth)
        
        let positionInterplation = LineInterpolation(inputRange: inputRange, outputRange: outputRangeForPosition)
        
        indicaterWidth = widthInterpolation.calculate(for: -contentOffset)
        indicaterPosition = positionInterplation.calculate(for: -contentOffset)
    }
    
    func index(of tab: Tab) -> Int {
        return tabs.firstIndex(of: tab) ?? 0
    }
    
    /// Tabs View
    @ViewBuilder
    func TabsView() -> some View {
        HStack(spacing: 0) {
            ForEach($tabs) { $tab in
                Text(tab.title)
                    .fontWeight(.semibold)
                    /// Saving Tab's MinX & Width for Calculatation Purposes
                    .offsetX { rect in
                        tab.minX = rect.minX
                        tab.width = rect.width
                    }
                
                if tabs.last != tab {
                    Spacer(minLength: 0)
                }
            }
        }
        .padding([.top, .horizontal], 15)
        .overlay(alignment: .bottomLeading, content: {
            Rectangle()
                .frame(width: indicaterWidth, height: 4)
                .offset(x: indicaterPosition, y: 10)
        })
        .foregroundColor(.white)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
