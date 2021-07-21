//
//  CustomTextField.swift
//  restaurant_search_App
//
//  Created by 佐藤駿樹 on 2021/07/18.
//

import UIKit

class CustomTextField: UITextField {

    //入力カーソル非表示
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
    
    //範囲選択カーソル非表示
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }
    
    //コピー・ペースト・選択のメニュー非表示
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }

}
