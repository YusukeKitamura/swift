//
//  ViewController.swift
//  MyCalc
//
//  Created by 北村裕介 on 2016/05/12.
//  Copyright © 2016年 北村裕介. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController {
    //計算結果を表示させるラベルを宣言
    var resultLabel = UILabel()
    let xButtonCount = 4
    let yButtonCount = 5
    
    var number1:Double = 0.0
    var number2:Double = 0.0
    var result:Double  = 0.0
    var operatorId:String = ""
    var pointFlag:Bool = false
    var pointPos1:Int = 0
    var pointPos2:Int = 0
    
        override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.blackColor()
        //画面の横幅のサイズを格納するメンバ変数
        let screenWidth:Double = Double(UIScreen.mainScreen().bounds.size.width)
        //画面の縦幅のサイズを格納するメンバ変数
        let screenHeight:Double = Double(UIScreen.mainScreen().bounds.size.height)
        let buttonMargin = 10.0
        var resultArea = 0.0
        switch screenHeight {
        case 480:
            resultArea = 100.0
        case 568:
            resultArea = 130.0
        case 667:
            resultArea = 160.0
        case 736:
            resultArea = 190.0
        default:
            resultArea = 0.0
        }
        
        //計算結果ラベルのフレーム位置と大きさ
        resultLabel.frame = CGRect(x:10, y: 30, width: screenWidth-30, height: resultArea-50)
        //計算結果ラベルの背景色
        resultLabel.backgroundColor = UIColor.yellowColor()
        //計算結果ラベルのフォントと文字サイズ
        resultLabel.font = UIFont(name: "Arial", size: 36)
        //計算結果ラベルのアラインメント
        resultLabel.textAlignment = NSTextAlignment.Right
        //計算結果ラベルの表示行数
        resultLabel.numberOfLines = 3
        //計算結果ラベルの初期値
        resultLabel.text = "0"
        //計算結果ラベルをViewControllerクラスのviewに設置
        self.view.addSubview(resultLabel)
        
        let buttonLabels = [
            "7", "8", "9", "*",
            "4", "5", "6", "-",
            "1", "2", "3", "+",
            "0", "C", "=", "/",
            ".", "00", "8%", "10%"
        ]
        
        let buttonWidth = (screenWidth - (buttonMargin * (Double(xButtonCount)+1))) / Double(xButtonCount)
        let buttonHeight = (screenHeight - resultArea - ((buttonMargin * Double(yButtonCount)+1))) / Double(yButtonCount)
        //繰り返し処理でボタンを配置
        for y in 0 ..< yButtonCount {
            for x in 0 ..< xButtonCount {
                let button = UIButton()
                let buttonPositionX = buttonMargin + (screenWidth - buttonMargin) / Double(xButtonCount) * Double(x)
                let buttonPositionY = resultArea + buttonMargin + (screenHeight - resultArea - buttonMargin) / Double(yButtonCount) * Double(y)
                button.frame = CGRect(x: buttonPositionX, y: buttonPositionY, width: buttonWidth, height: buttonHeight)
                button.backgroundColor = UIColor.purpleColor()
                //ボタンのラベルタイトルを取り出すインデックス番号
                let buttonNumber = y * xButtonCount + x
                //ボタンのラベルタイトル
                button.setTitle(buttonLabels[buttonNumber], forState: UIControlState.Normal)
                //button.addTarget(self, action: #selector(ViewController.buttonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                button.addTarget(self, action: #selector(ViewController.buttonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                self.view.addSubview(button)
                
            }
        }
    }
    
    //ボタンがタップされた時のメソッド
    func buttonTapped(sender:UIButton){
        let tappedButtonTitle:String = sender.currentTitle!
        //ボタンのタイトルで条件分岐
        switch tappedButtonTitle {
        case "00", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
            numberButtonTapped(tappedButtonTitle)
        case "+", "-", "*", "/":
            operatorButtonTapped(tappedButtonTitle)
        case "=":
            equalButtonTapped(tappedButtonTitle)
        case ".":
            pointButtonTapped(tappedButtonTitle)
        case "8%", "10%":
            taxButtonTapped(tappedButtonTitle)
        default:
            clearButtonTapped(tappedButtonTitle)
        }
        
    }
    
    func numberButtonTapped(tappedButtonTitle:String) {
        if tappedButtonTitle == "00" {
            numberButtonTapped("0")
            numberButtonTapped("0")
        } else {
            var tappedButtonNum:Double = (tappedButtonTitle as NSString).doubleValue
            if (number1 < 0.0) {
                tappedButtonNum = -tappedButtonNum
            }
            if (pointFlag) {
                pointPos1 += 1
                let pointDot:Double = Double(pointPos1)
                number1 = number1 + pow(0.1, pointDot) * tappedButtonNum
            } else {
                number1 = number1 * 10 + tappedButtonNum
            }
            switch pointPos1 {
            case 0:
                resultLabel.text = NSString(format: "%.0F", number1) as String
            case 1:
                resultLabel.text = NSString(format: "%.1F", number1) as String
            case 2:
                resultLabel.text = NSString(format: "%.2F", number1) as String
            case 3:
                resultLabel.text = NSString(format: "%.3F", number1) as String
            default:
                resultLabel.text = NSString(format: "%.4F", number1) as String
            }
        }
    }
    
    func operatorButtonTapped(tappedButtonTitle:String) {
        operatorId = tappedButtonTitle
        number2 = number1
        number1 = 0.0
        pointPos2 = pointPos1
        pointPos1 = 0
        pointFlag = false
    }
    
    func equalButtonTapped(tappedButtonTitle:String) {
        switch operatorId {
        case "+":
            pointPos1 = max(pointPos1, pointPos2)
            result = number2 + number1
        case "-":
            pointPos1 = max(pointPos1, pointPos2)
            result = number2 - number1
        case "*":
            pointPos1 = pointPos1 + pointPos2
            result = number2 * number1
        case "/":
            if (number1 == 0) {
                number1 = 0
                pointPos1 = 0
                resultLabel.text = "Divided by zero error!"
                return
            } else {
                pointPos1 = max(0, pointPos1 - pointPos2)
                result = number2 / number1
            }
        default:
            print("Other")
        }
        number1 = result
        if (result - floor(result) <= 0.0) {
            pointPos1 = 0
        }
        switch pointPos1 {
        case 0:
            resultLabel.text = NSString(format: "%.0F", number1) as String
        case 1:
            resultLabel.text = NSString(format: "%.1F", number1) as String
        case 2:
            resultLabel.text = NSString(format: "%.2F", number1) as String
        case 3:
            resultLabel.text = NSString(format: "%.3F", number1) as String
        default:
            resultLabel.text = NSString(format: "%.4F", number1) as String
        }
        pointFlag = false
    }
    
    func pointButtonTapped(tappedButtonTitle:String) {
        pointFlag = true
    }
    
    func taxButtonTapped(tappedButtonTitle:String) {
        switch tappedButtonTitle {
        case "8%":
            result = number1 * 1.08
            pointPos1 = pointPos1 + 2
        case "10%":
            result = number1 * 1.1
            pointPos1 = pointPos1 + 1

        default:
            print("Other")
        }
        number1 = result
        if (result - floor(result) <= 0.0) {
            pointPos1 = 0
        }
        switch pointPos1 {
        case 0:
            resultLabel.text = NSString(format: "%.0F", number1) as String
        case 1:
            resultLabel.text = NSString(format: "%.1F", number1) as String
        case 2:
            resultLabel.text = NSString(format: "%.2F", number1) as String
        case 3:
            resultLabel.text = NSString(format: "%.3F", number1) as String
        default:
            resultLabel.text = NSString(format: "%.4F", number1) as String
        }
        pointFlag = false
    }
    
    func clearButtonTapped(tappedButtonTitle:String) {
        number1 = 0
        number2 = 0
        result = 0
        operatorId = ""
        pointPos1 = 0
        pointPos2 = 0
        pointFlag = false
        resultLabel.text = "0"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

