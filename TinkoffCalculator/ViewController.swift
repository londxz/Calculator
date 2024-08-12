//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Родион Холодов on 10.08.2024.
//

import UIKit

enum CalculationError: Error {
    case divisionByZero
}


enum Operation: String {
    case add = "+"
    case substract = "-"
    case multiply = "x"
    case divide = "/"
    
    enum OperationPriority: Int {
        case second = 0
        case first
    }
    
    func priority() -> Int {
        switch self {
        case .add, .substract: 
            return OperationPriority.second.rawValue
        case .divide, .multiply: 
            return OperationPriority.first.rawValue
        }
    }
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

enum CalculationHistoryItem {
    case number(Double)
    case operation(Operation)
}

class ViewController: UIViewController {

    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let buttonText = sender.currentTitle else { return }
        
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
    
    @IBAction func operationButtonPressed(_ sender: UIButton) {
        guard
            let buttonText = sender.currentTitle, // присвоили строку кнопки
            let buttonOperation = Operation(rawValue: buttonText) // присвоили операцию
        else { return }
        guard
            let labelText = label.text, // из кнопки делаем строку-число
            let labelNumber = numberFormatter.number(from: labelText)?.doubleValue // привели строку к числу
        else { return }
        calculationHistoryItem.append(.number(labelNumber))
        calculationHistoryItem.append(.operation(buttonOperation))
        //print("add \(labelNumber)")
        //print("add \(buttonOperation)")
        label.text = labelText
        flagOperationPressed = true
    }
    
    var flagOperationPressed = false
    var calculationHistoryItem = [CalculationHistoryItem]()
    @IBAction func clearButtonPressed() {
        calculationHistoryItem.removeAll()
        resetLabelText()
    }
    
    @IBAction func calculateButtonPressed() {
        guard
            let labelText = label.text,
            let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
        else { return }
        
        calculationHistoryItem.append(.number(labelNumber))
        //print("add \(labelNumber)")
        
        do {
            let result = try calculate()
            label.text = numberFormatter.string(from: NSNumber(value: result))
        } catch {
            label.text = "Error :c"
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
        // Do any additional setup after loading the view.
        //let op = Operation.OperationPriority.first
        //print(op.rawValue)
    }
    
    func resetLabelText() {
        label.text = "0"
    }
    
    func calculate() throws -> Double {
        guard case .number(let firstNumber) = calculationHistoryItem[0] else { return 0 } // добавил первое число
        
        var currentResult = firstNumber // первое число - текущий ответ
        
        for index in stride(from: 1, to: calculationHistoryItem.count - 1, by: 2) {
            guard
                case .operation(let operation) = calculationHistoryItem[index],
                case .number(let number) = calculationHistoryItem[index + 1]
            else { break }
            currentResult = try operation.calculate(currentResult, number)
            //print("counted \(currentResult)")
        }
        return currentResult
    }

}

