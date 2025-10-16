//
//  LogoView.swift
//  MyContactPoint
//
//  Created by Taylor Larson on 9/19/25.
//

import SwiftUI

enum LogoSize {
    case small
    case medium
    case large
    case extraLarge
    
    var size: CGFloat {
        switch self {
        case .small: return 40
        case .medium: return 60
        case .large: return 80
        case .extraLarge: return 120
        }
    }
}

struct LogoView: View {
    let size: LogoSize
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue)
                .frame(width: size.size, height: size.size)
            
            Image(systemName: "baseball.fill")
                .font(.system(size: size.size * 0.6))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        LogoView(size: .small)
        LogoView(size: .medium)
        LogoView(size: .large)
        LogoView(size: .extraLarge)
    }
}
