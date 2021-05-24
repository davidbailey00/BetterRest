//
//  ContentView.swift
//  BetterRest
//
//  Created by David Bailey on 22/05/2021.
//

import SwiftUI

struct ContentView: View {
    @State private var wakeUp = getDefaultWakeTime()
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var showingError = false
    
    var calculatedBedtime: String {
        let model = SleepCalculator()

        let components = Calendar.current.dateComponents(
            [.hour, .minute],
            from: wakeUp
        )
        let hour = components.hour! * 60 * 60
        let minute = components.minute! * 60 * 60

        do {
            let prediction = try model.prediction(
                wake: Double(hour + minute),
                estimatedSleep: sleepAmount,
                coffee: Double(coffeeAmount)
            )

            let sleepTime = wakeUp - prediction.actualSleep

            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: sleepTime)
        } catch {
            showingError = true
            return ""
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("When do you wake up?")) {
                    DatePicker(
                        "Wake up time",
                        selection: $wakeUp,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .datePickerStyle(WheelDatePickerStyle())
                }

                Section(header: Text("Sleep goal & coffee")) {
                    Stepper(
                        value: $sleepAmount,
                        in: 4 ... 12,
                        step: 0.25
                    ) {
                        Text("\(sleepAmount, specifier: "%g") hours sleep goal")
                    }

                    Picker("Daily coffee amount", selection: $coffeeAmount) {
                        ForEach(1 ..< 11, id: \.self) {
                            if $0 == 1 {
                                Text("1 cup")
                            } else {
                                Text("\($0) cups")
                            }
                        }
                    }
                }

                Section(header: Text("Ideal bedtime")) {
                    HStack {
                        Text("Your ideal bedtime is:")
                        Spacer()
                        Text(calculatedBedtime).font(.headline)
                    }
                }
            }
            .navigationBarTitle("BetterRest")
            .alert(isPresented: $showingError) {
                Alert(
                    title: Text("Something went wrong"),
                    message: Text("There was a problem calculating your bedtime")
                )
            }
        }
    }

    static func getDefaultWakeTime() -> Date {
        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        return Calendar.current.date(from: components)!
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
