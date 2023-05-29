//
//  PieChartCell.swift
//  ChartView
//
//  Created by András Samu on 2019. 06. 12..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

struct PieSlice: Identifiable {
    var id = UUID()
    var startDeg: Double
    var endDeg: Double
    var value: Double
    var normalizedValue: Double
}

public struct PieChartCell : View {
    @State private var show:Bool = false
    var rect: CGRect
    var radius: CGFloat {
        return min(rect.width, rect.height)/2
    }
    var startDeg: Double
    var endDeg: Double
    var path: Path {
        var path = Path()
        path.addArc(center:rect.mid , radius:self.radius, startAngle: Angle(degrees: self.startDeg), endAngle: Angle(degrees: self.endDeg), clockwise: false)
        path.addLine(to: rect.mid)
        path.closeSubpath()
        return path
    }
    var index: Int
    var backgroundColor:Color
    var accentColor:Color
    var showPercentage: Bool=true
    
    private var triangleAngle: Angle {
        return Angle(degrees: self.endDeg - self.startDeg)
    }
    private var percentage: Double {
        return (self.triangleAngle.degrees/360)*100
    }
    public var body: some View {
        ZStack {
            path
                .fill()
                .foregroundColor(self.accentColor)
            if self.showPercentage {
                Text("\(String(format: "%.0f", self.percentage))%")
                    .font(.caption)
                    .offset(self.triangleAngle.degrees != 360 ? self.getTriangleCenterOffsetWith(percentage: 0.75) : .zero)
            }
                }.scaleEffect(self.show ? 1 : 0)
            .animation(Animation.spring().delay(Double(self.index) * 0.04))
            .onAppear(){
                self.show = true
            }.overlay(self.triangleAngle.degrees != 360 ?  AnyView(path.stroke(self.backgroundColor, lineWidth: 2)) : AnyView(EmptyView()))
    }
    
    private func getTriangleCenterOffsetWith(percentage: Double) -> CGSize {
        let theta = Angle(degrees: self.startDeg).radians + (self.triangleAngle.radians)/2
        let dx = cos(theta)*self.radius*percentage
        let dy = sin(theta)*self.radius*percentage
        return CGSize(width: dx, height: dy)
    }
}

extension CGRect {
    var mid: CGPoint {
        return CGPoint(x:self.midX, y: self.midY)
    }
}

#if DEBUG
struct PieChartCell_Previews : PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            PieChartCell(rect: geometry.frame(in: .local),startDeg: 0.0,endDeg: 90.0, index: 0, backgroundColor: .blue, accentColor: Color(red: 225.0/255.0, green: 97.0/255.0, blue: 76.0/255.0), showPercentage: false)
            }
        
    }
}
#endif
