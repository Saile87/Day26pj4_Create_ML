//
//  ContentView.swift
//  BetterRest
//
//  Created by Elias Breitenbach on 16.04.23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertessage = ""
    @State private var showAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    struct GrowingButton: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .background(.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .scaleEffect(configuration.isPressed ? 1.2 : 1)
                .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
        }
    }
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("When do you want to wake up?")
                            .font(.headline)
                        
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }
                Section {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Desired amount of sleep")
                            .font(.headline)
                        
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                }
                Section {
                    Picker("1 Cup", selection: $coffeeAmount) {
                        ForEach(0..<21) {
                            Text("\($0) Cups")
                        }
                        
                    }
                    //                    VStack(alignment: .leading, spacing: 0) {
                    //                        Text("Daily coffee intake")
                    //                            .font(.headline)
                    //                        Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in:  1...20)
                }  header: {
                    Text("Daily coffee intake")
                }
                
                Button("Calculate", action: calculateBedtime) 
                    .buttonStyle(GrowingButton())
                
            }
            .navigationTitle("Better Rest")

            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertessage)
            }
        }
    }
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            //            SleepCalculator erstellte Datei in CoreML
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            //            wake: aus der SleepCalculator datei
            //            estimatedSleep: aus der SleepCalculator datei
            //            coffee: aus der SleepCalculator datei
            
            let sleepTime = wakeUp - prediction.actualSleep
            //            actualSleep: aus der SleepCalculator datei
            alertTitle = "Your ideal bedtime is..."
            alertessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            alertTitle = "Error"
            alertessage = "Sorry, there was a problem calculating your bedtime"
        }
        showAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
