import SwiftUI
import Charts

struct YearlyBreakdownView: View {
    let breakdown: [MonthlyCost]
    let currencyCode: String
    let yearlyTotal: Double
    @State private var selectedMonth: MonthlyCost?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Önümüzdeki 12 ay tahmini gider")
                    .font(.headline)
                Chart(breakdown) { item in
                    BarMark(
                        x: .value("Ay", item.monthLabel),
                        y: .value("Tutar", item.total)
                    )
                    .foregroundStyle(.purple)
                    if let selectedMonth, selectedMonth.id == item.id {
                        RuleMark(x: .value("Ay", item.monthLabel))
                            .foregroundStyle(.gray.opacity(0.4))
                        PointMark(
                            x: .value("Ay", item.monthLabel),
                            y: .value("Tutar", item.total)
                        )
                        .annotation(position: .overlay, alignment: .top) {
                            Text(formattedAmount(item.total))
                                .font(.caption.bold())
                                .padding(6)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .frame(height: 260)
                .chartYAxisLabel("Tutar")
                .chartXAxisLabel("Ay")
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        ZStack(alignment: .topLeading) {
                            Rectangle()
                                .fill(.clear)
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            let plotFrame = geo[proxy.plotAreaFrame]
                                            let origin = plotFrame.origin
                                            let location = CGPoint(x: value.location.x - origin.x, y: value.location.y - origin.y)
                                            guard plotFrame.contains(value.location) else {
                                                selectedMonth = nil
                                                return
                                            }
                                            if let month: String = proxy.value(atX: location.x) {
                                                selectedMonth = breakdown.first { $0.monthLabel == month }
                                            }
                                        }
                                        .onEnded { _ in
                                            selectedMonth = nil
                                        }
                                )

                            if let selectedMonth,
                               let positionX = proxy.position(forX: selectedMonth.monthLabel) {
                                let frame = geo[proxy.plotAreaFrame]
                                let tooltipX = frame.origin.x + positionX - 40
                                let tooltipY = frame.origin.y + frame.height * 0.1
                                Text(formattedAmount(selectedMonth.total))
                                    .font(.caption.bold())
                                    .padding(6)
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                                    .offset(x: tooltipX, y: tooltipY)
                            }
                        }
                    }
                }

                Text("Toplam yıllık tahmini: \(yearlyText)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Yıllık Detay")
        .toolbar(.visible, for: .navigationBar)
        .onDisappear {
            selectedMonth = nil
        }
    }

    private var yearlyText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: yearlyTotal as NSNumber) ?? "-"
    }

    private func formattedAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: value as NSNumber) ?? "\(value)"
    }
}
