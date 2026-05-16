//
//  GrowthEnergyMiniCard.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 14/05/2026.
//

import SwiftUI

struct GrowthEnergyMiniCard: View {
    
    let energy: GrowthEnergy
    let isSelected: Bool
    let action: () -> Void
    let infoAction: () -> Void
    
    private var strokeColor: Color {
        isSelected ? energy.color : Color.black.opacity(0.22)
    }
    
    private var strokeWidth: CGFloat {
        isSelected ? 2.4 : 1
    }
    
    private var tagBackgroundColor: Color {
        energy.color.opacity(0.14)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 7) {
                imageArea
                
                Text(energy.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(energy.color)
                
                Text(energy.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                
               // bestForTag
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .frame(height: 190)
            .background(Color.white.opacity(0.82))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(strokeColor, lineWidth: strokeWidth)
            )
            .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
    
    private var imageArea: some View {
        ZStack(alignment: .topTrailing) {
            Image(energy.assetName)
                .resizable()
                .scaledToFit()
                .frame(height: 68)
                .frame(maxWidth: .infinity)
            
            Button {
                infoAction()
            } label: {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(energy.color)
                    .background(
                        Circle()
                            .fill(.white)
                    )
            }
            .buttonStyle(.plain)
        }
        .frame(height: 72)
    }
    
//    private var bestForTag: some View {
//        VStack(alignment: .leading, spacing: 2) {
//            Text("Best for")
//            Text(energy.bestFor)
//        }
//        .font(.caption2)
//        .foregroundStyle(energy.color)
//        .lineLimit(2)
//        .padding(.horizontal, 10)
//        .padding(.vertical, 7)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(
//            Capsule()
//                .fill(tagBackgroundColor)
//        )
//    }
}

#Preview {
    GrowthEnergyMiniCard(
        energy: .bluey,
        isSelected: true
    ) {
        
    } infoAction: {
        
    }
    .padding()
    .background(Color("background"))
}
