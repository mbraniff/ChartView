//
//  PieChartRow.swift
//  ChartView
//
//  Created by András Samu on 2019. 06. 12..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct PieChartRow : View {
    var data: [DataPoint]
    var backgroundUIColor: UIColor
    var uiColors: [UIColor]
    
    var backgroundColor: Color {
        return Color(backgroundUIColor) 
    }
    var colors: [Color] {
        return self.uiColors.map{ Color($0) }
    }
    
    var slices: [PieSlice] {
        var tempSlices:[PieSlice] = []
        var lastEndDeg:Double = 0
        let maxValue = data.reduce(0, { result, data in
            result + data.value
        })
        for slice in data {
            let normalized:Double = Double(slice.value)/Double(maxValue)
            let startDeg = lastEndDeg
            let endDeg = lastEndDeg + (normalized * 360)
            lastEndDeg = endDeg
            tempSlices.append(PieSlice(startDeg: startDeg, endDeg: endDeg, value: slice.value, normalizedValue: normalized))
        }
        return tempSlices
    }
    
    var colorGradient: [Color] {
        var gradientArray = self.uiColors.count == 1 ? GradientArray(startColor: uiColors[0]).getArray(count: self.slices.count, maxPercentage: 0.8) : MultiGradientArray(colors: self.uiColors).getArray(count: self.slices.count)
        return gradientArray
    }
    
    @Binding var showIndex: Int?
    @Binding var touchLocation: CGPoint?
    var touchesEnabled: Bool
    
    public init(data: [DataPoint], backgroundColor: UIColor, colors: [UIColor], showIndex: Binding<Int?>, touchLocation: Binding<CGPoint?>, touchesEnabled: Bool = true) {
        self.data = data
        self.backgroundUIColor = backgroundColor
        self.uiColors = colors
        self._showIndex = showIndex
        self._touchLocation = touchLocation
        self.touchesEnabled = touchesEnabled
    }
    
    @State private var currentTouchedIndex = -1 {
        didSet {
            if oldValue != currentTouchedIndex {
                if currentTouchedIndex == -1 {
                    self.showIndex = nil
                } else {
                    self.showIndex = currentTouchedIndex
                }
            }
        }
    }
    
    public var body: some View {
        HStack(alignment: .center) {
            GeometryReader { geometry in
                ForEach(0..<self.slices.count, id: \.self){ i in
                    PieChartCell(rect: geometry.frame(in: .local), startDeg: self.slices[i].startDeg, endDeg: self.slices[i].endDeg, index: i, backgroundColor: self.backgroundColor,accentColor: self.colorGradient[i])
                        .scaleEffect(self.currentTouchedIndex == i ? 1.1 : 1)
                        .animation(Animation.spring(), value: self.currentTouchedIndex)
                }
                .gesture(self.touchesEnabled ? AnyGesture(DragGesture()
                    .onChanged({ value in
                        let rect = geometry.frame(in: .local)
                        let isTouchInPie = isPointInCircle(point: value.location, circleRect: rect)
                        if isTouchInPie {
                            let touchDegree = degree(for: value.location, inCircleRect: rect)
                            self.currentTouchedIndex = self.slices.firstIndex(where: { $0.startDeg < touchDegree && $0.endDeg > touchDegree }) ?? -1
                            self.touchLocation = value.location
                        } else {
                            self.touchLocation = nil
                            self.currentTouchedIndex = -1
                        }
                    })
                    .onEnded({ value in
                        UIScrollView.appearance().isScrollEnabled = true
                        self.currentTouchedIndex = -1
                        self.touchLocation = nil
                    })
                ) : AnyGesture(DragGesture().onChanged({ _ in }).onEnded({ _ in })))
            }
            
            VStack(alignment: .leading) {
                ForEach(0..<self.slices.count, id: \.self) { i in
                    HStack {
                        Rectangle().frame(width: 10, height: 10).foregroundColor(self.colorGradient[i])
                            .border(.black)
                        Text(data[i].name)
                    }
                    .scaleEffect(self.currentTouchedIndex == i ? 1.1 : 1)
                    .animation(Animation.spring(), value: self.currentTouchedIndex)
                    .blur(radius: self.currentTouchedIndex != -1 ? self.currentTouchedIndex != i ? 0.85 : 0 : 0)
                }
            }
        }
    }
    
    public struct DataPoint {
        let name: String
        let value: Double
        
        public init(value: Double, name: String = "") {
            self.value = value
            self.name = name
        }
    }
}

extension Array where Element == PieChartRow.DataPoint {
    init(integers: [IntegerLiteralType]) {
        self = integers.map { PieChartRow.DataPoint(value: Double($0)) }
    }
}


#if DEBUG
struct PieChartRow_Previews : PreviewProvider {
    static let data1 = Array(integers: [8,23,54,32,12,37,7,23,43])
    static let data2 = Array(integers: [0])
    static var previews: some View {
        Group {
            PieChartRow(data:data1, backgroundColor: UIColor(red: 252.0/255.0, green: 236.0/255.0, blue: 234.0/255.0, alpha: 1.0), colors: [UIColor(red: 225.0/255.0, green: 97.0/255.0, blue: 76.0/255.0, alpha: 1.0), .blue, .green, .yellow], showIndex: Binding.constant(nil), touchLocation: Binding.constant(nil))
            PieChartRow(data:data2, backgroundColor: UIColor(red: 252.0/255.0, green: 236.0/255.0, blue: 234.0/255.0, alpha: 1.0), colors: [UIColor(red: 225.0/255.0, green: 97.0/255.0, blue: 76.0/255.0, alpha: 1.0)], showIndex: Binding.constant(nil), touchLocation: Binding.constant(nil))
        }
    }
}
#endif
