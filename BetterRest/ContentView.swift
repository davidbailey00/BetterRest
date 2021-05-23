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

    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

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
                .textCase(nil)

                Section(header: Text("Desired amount of sleep")) {
                    Stepper(
                        value: $sleepAmount,
                        in: 4 ... 12,
                        step: 0.25
                    ) {
                        Text("\(sleepAmount, specifier: "%g") hours")
                    }
                }
                .textCase(nil)

                Section(header: Text("Daily coffee intake")) {
                    Stepper(value: $coffeeAmount, in: 1 ... 20) {
                        if coffeeAmount == 1 {
                            Text("1 cup")
                        } else {
                            Text("\(coffeeAmount) cups")
                        }
                    }
                }
                .textCase(nil)
            }
            .navigationBarTitle("BetterRest")
            .navigationBarItems(
                trailing: Button(action: calculateBedtime) {
                    Text("Calculate")
                }
            )
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage)
                )
            }
        }
    }

    func calculateBedtime() {
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

            alertTitle = "Your ideal bedtime is:"
            alertMessage = formatter.string(from: sleepTime)
        } catch {
            alertTitle = "Something went wrong"
            alertMessage = "There was a problem calculating your bedtime"
        }

        showingAlert = true
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
