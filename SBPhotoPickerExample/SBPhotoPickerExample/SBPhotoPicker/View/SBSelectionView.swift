

import UIKit


@IBDesignable
class SBSelectionView: UIView {

    var selectionString: String = "" {
        didSet {
            if selectionString != oldValue {
                setNeedsDisplay()
            }
        }
    }
    
    var settings: SBPhotoPickerSettings = SBSettings()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else {
          return
        }
        
        let shadow2Offset = CGSize(width: 0.1, height: -0.1);
        let shadow2BlurRadius: CGFloat = 2.5;
        
        let checkmarkFrame = bounds;
        
        let group = CGRect(x: checkmarkFrame.minX + 3, y: checkmarkFrame.minY + 3, width: checkmarkFrame.width - 6, height: checkmarkFrame.height - 6)
        
        let checkedOvalPath = UIBezierPath(ovalIn: CGRect(x: group.minX + floor(group.width * 0.0 + 0.5), y: group.minY + floor(group.height * 0.0 + 0.5), width: floor(group.width * 1.0 + 0.5) - floor(group.width * 0.0 + 0.5), height: floor(group.height * 1.0 + 0.5) - floor(group.height * 0.0 + 0.5)))
        context.saveGState()
        context.setShadow(offset: shadow2Offset, blur: shadow2BlurRadius, color: settings.selectionShadowColor.cgColor)
        settings.selectionFillColor.setFill()
        checkedOvalPath.fill()
        context.restoreGState()
        
        settings.selectionStrokeColor.setStroke()
        checkedOvalPath.lineWidth = 1
        checkedOvalPath.stroke()
        
        
        context.setFillColor(UIColor.white.cgColor)
        
        if (settings.maxNumberOfSelections == 1) {
            context.setStrokeColor(UIColor.white.cgColor)
            
            let checkPath = UIBezierPath()
            checkPath.move(to: CGPoint(x: 7, y: 12.5))
            checkPath.addLine(to: CGPoint(x: 11, y: 16))
            checkPath.addLine(to: CGPoint(x: 17.5, y: 9.5))
            checkPath.stroke()
            return;
        }
        
        let size = selectionString.size(attributes: settings.selectionTextAttributes)

        selectionString.draw(in: CGRect(x: checkmarkFrame.midX - size.width / 2.0,
            y: checkmarkFrame.midY - size.height / 2.0,
            width: size.width,
            height: size.height), withAttributes: settings.selectionTextAttributes)
    }
}
