//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Родион Холодов on 10.08.2024.
//

import UIKit

class Stack<T: Equatable> {
    var items = [T]()
    
    func push(_ item: T) {
        items.append(item)
    }
    
    func pop() -> T? {
        let last = items.last
        if items.isEmpty == false {
            items.removeLast()
        }
        return last
    }
    
    func peek() -> T? {
        if let last = items.last {
            return last
        } else {
            return nil
        }
    }
    
    func count() -> Int {
        return items.count
    }
    
    func printStack() {
        for i in items {
            print(i, terminator: " ")
        }
        print()
    }
    
    func isContain(_ item: T) -> Bool {
        return items.contains(where: {$0 == item})
    }
    
    func deleteStack() {
        items.removeAll()
    }
}
    
    enum CalculationError: Error {
        case divisionByZero
    }
    
    enum Operation: String {
        case add = "+"
        case substract = "-"
        case multiply = "x"
        case divide = "/"
        
        func calculate(_ num1: Double, _ num2: Double) throws -> Double {
            switch self {
            case .add: 
                return num1 + num2
                
            case .substract:
                return num1 - num2
                
            case .multiply:
                return num1 * num2
                
            case .divide:
                if num2 == 0 {
                    throw CalculationError.divisionByZero
                }
                return num1 / num2
            }
        }
    }
    
    enum CalculationHistoryItem: Equatable {
        case number(Double)
        case operation(Operation)
    }
    
    class ViewController: UIViewController {
        
        @IBAction func buttonPressed(_ sender: UIButton) {
            guard let buttonText = sender.currentTitle else { return }
            
            if label.text == "Error :c" { resetLabelText() }
            
            if flagOperationPressed == true {
                resetLabelText()
                flagOperationPressed = false
            }
            
            if buttonText == "," && label.text?.contains(",") == true {
                return
            }
            
            if label.text == "0" && buttonText != ","{
                label.text = buttonText
            } else {
                label.text?.append(buttonText)
            }
            
        }
        
        var flagEarlyCalc = false
        var flagFirstPrAppeared = false
        
        @IBAction func operationButtonPressed(_ sender: UIButton) {
            
            if flagOperationPressed == true { return }
            
            guard
                let buttonText = sender.currentTitle,
                let buttonOperation = Operation(rawValue: buttonText)
            else { return }
            
            guard
                let labelText = label.text,
                let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
            else { return }
            
            calculationHistoryItem.append(.number(labelNumber))
            calculationHistoryItem.append(.operation(buttonOperation))
            
            numberStack.push(labelNumber)
        
            if operationStack.peek() == .divide || operationStack.peek() == .multiply {
                
                if buttonOperation == .add || buttonOperation == .substract {
                    guard
                        let secondNum = numberStack.pop(),
                        let firstNum = numberStack.pop(),
                        let operation = operationStack.pop()
                    else { return }
                    do {
                        let preResult = try operation.calculate(firstNum, secondNum)

                        calculationHistoryItem.removeLast()
                        calculationHistoryItem.removeLast()
                        calculationHistoryItem.removeLast()
                        calculationHistoryItem.removeLast()
                        
                        calculationHistoryItem.append(.number(preResult))
                        calculationHistoryItem.append(.operation(buttonOperation))
                        
                        numberStack.push(preResult)
                        print("Did \(firstNum) \(operation) \(secondNum)")
                        print("PRERES: \(preResult)")
                    } catch {
                        label.text = "Error :c"
                        clearHistoryAndStacks()
                        return
                    }
                }
            }
            
            operationStack.push(buttonOperation)
            print(calculationHistoryItem)
            
            print("NUMBER:")
            numberStack.printStack()
            print("OPERATION:")
            operationStack.printStack()

            label.text = labelText
            
            flagOperationPressed = true
        }
        
        var calculationHistoryItem = [CalculationHistoryItem]()
        var flagOperationPressed = false
        var numberStack = Stack<Double>()
        var operationStack = Stack<Operation>()
        
        @IBAction func clearButtonPressed() {
            calculationHistoryItem.removeAll()
            resetLabelText()
        }
        
        @IBAction func calculateButtonPressed() {
            guard
                let labelText = label.text,
                let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
            else { return }

            if operationStack.peek() == .divide || operationStack.peek() == .multiply {
  
                guard
                    let firstNum = numberStack.pop(),
                    let operation = operationStack.pop()
                else { return }
                
                calculationHistoryItem.removeLast()
                calculationHistoryItem.removeLast()
                
                do {
                    let preResult = try operation.calculate(firstNum, labelNumber)
                    calculationHistoryItem.append(.number(preResult))
                    
                    print("Did \(firstNum) \(operation) \(labelNumber)")
                    print("PRERES: \(preResult)")
                    print(calculationHistoryItem)
                } catch {
                    label.text = "Error :c"
                    clearHistoryAndStacks()
                    return
                }
                
            }
            
            calculationHistoryItem.append(.number(labelNumber))
            
            print("add IN CALC BUTTON \(labelNumber)")
            print(calculationHistoryItem)
            
            do {
                let result = try calculate()
                label.text = numberFormatter.string(from: NSNumber(value: result))
                print("result: \(result)")
            } catch {
                label.text = "Error :c"
                clearHistoryAndStacks()
                return
            }
            
            calculationHistoryItem.removeAll()
        }
        
        @IBOutlet weak var label: UILabel!
        
        lazy var numberFormatter: NumberFormatter = {
            let numberFormatter = NumberFormatter()
            numberFormatter.usesGroupingSeparator = false
            numberFormatter.locale = Locale(identifier: "ru_RU")
            numberFormatter.numberStyle = .decimal
            
            return numberFormatter
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            resetLabelText()
        }
        
        func resetLabelText() {
            label.text = "0"
        }
        
        func clearHistoryAndStacks() {
            calculationHistoryItem.removeAll()
            numberStack.deleteStack()
            operationStack.deleteStack()
        }
        
        @IBAction func unwindAction(unwindSeque: UIStoryboardSegue) {
            
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
             
            guard segue.identifier == "CALCULATIONS_LIST",
                  let calculationsListVC = segue.destination as? CalculationsListViewController else { return }
            calculationsListVC.result = label.text
            
        }
        
        func calculate() throws -> Double {
            guard case .number(let firstNumber) = calculationHistoryItem[0] else { return 0 }
            
            var currentResult = firstNumber
            
            for index in stride(from: 1, to: calculationHistoryItem.count - 1, by: 2) {
                guard
                    case .operation(let operation) = calculationHistoryItem[index],
                    case .number(let number) = calculationHistoryItem[index + 1]
                else { break }
                currentResult = try operation.calculate(currentResult, number)
            }
            return currentResult
        }
    }
