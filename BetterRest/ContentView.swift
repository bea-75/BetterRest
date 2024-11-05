//
//  ContentView.swift
//  BetterRest
//
//  Created by Mobile on 9/23/24.
//

import CoreML
import SwiftUI

struct ClearBack: ViewModifier
{
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: 250)
            .padding(30)
            .background(Color(red: 0.0, green: 0.00, blue: 0.0, opacity: 0.4))
            .clipShape(.rect(cornerRadius: 15))
    }
}

extension View {
    func clearBack() -> some View {
        modifier(ClearBack())
    }
}

struct ContentView: View 
{
    static var defaultWakeTime: Date
    {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var bedtime: Date
    {
        do
        {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            return wakeUp - prediction.actualSleep
        }
        catch
        {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
            showingAlert = true
            return Date.now
        }
    }
    
    
    
    var body: some View 
    {
        ZStack
        {
            RadialGradient(colors: [Color(red: 0.10, green: 0.25, blue: 0.60), Color(red: 0.10, green: 0.10, blue: 0.20)], center: .center, startRadius: 20, endRadius: 450)
            
            VStack(spacing: 10)
            {
                Text("Better Rest")
                    .font(.largeTitle.weight(.bold))
                    .frame(maxWidth: 250)
                    .padding(10)
                    .background(Color(red: 0.0, green: 0.00, blue: 0.0, opacity: 0.4))
                    .clipShape(.rect(cornerRadius: 15))
                
                VStack(spacing: 15)
                {
                    VStack
                    {
                        Text("When do you want to wake up?")
                            .font(.headline)
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    
                    VStack
                    {
                        Text("Desired amount of sleep")
                            .font(.headline)
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                            .font(.headline)
                    }
                    
                    VStack
                    {
                        Text("Daily coffee intake: ^[\(coffeeAmount) cup](inflect: true)")
                            .font(.headline)
                        Picker("", selection: $coffeeAmount)
                        {
                            ForEach(1..<22)
                            {
                                Text($0 - 1, format: .number)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                }
                .clearBack()
                
                VStack
                {
                    Text("Reccomended Bedtime:")
                    Text(bedtime, format: .dateTime.hour().minute())
                }
                .font(.title2.weight(.bold))
                .clearBack()
            }
            .foregroundStyle(Color(red: 0.80, green: 0.80, blue: 1.00))
        }
        .ignoresSafeArea()
        .alert(alertTitle, isPresented: $showingAlert)
        {
            Button("OK") { }
        }
        message:
        {
            Text(alertMessage)
        }
        .preferredColorScheme(.dark)
    }
    
}

#Preview 
{
    ContentView()
}
