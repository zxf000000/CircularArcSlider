//
//  SliderView.swift
//  SliderDemo
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

class SliderView: UIView {
    
    var minValue: CGFloat = 0
    var maxValue: CGFloat = 1
    var initialValue: CGFloat = 0
    
    public private(set) var currentValue: CGFloat = 0
    
    var valueDidChanged: ((CGFloat) -> Void)?
    
    private var ball: UIView! = UIView()
    private var lineLayer: CAShapeLayer = CAShapeLayer()
    private var progressLineLayer: CAShapeLayer = CAShapeLayer()
    
    private var radius: CGFloat! = 0
    private var startAngle: CGFloat! = 0
    private var endAngle: CGFloat! = 0
    private var totalAngle: CGFloat! = 0
    
    private var centerPoint: CGPoint! = .zero
    
    private var panGes: UIPanGestureRecognizer!
    
    private var horizontalMargin: CGFloat!
    private var verticalMargin: CGFloat!
    private var ballRadius: CGFloat!
    private var ballColor: UIColor!
    private var lineColor: UIColor!
    private var progressColor: UIColor!
    
    private var startX: CGFloat = 0
    
    private var didLayout: Bool = false
    
    init(frame: CGRect, horizontalMargin: CGFloat? = 20, verticalMargin: CGFloat? = 20, ballRadius: CGFloat? = 15, ballColor: UIColor? = .white, lineColor: UIColor? = UISlider.appearance().tintColor ?? .systemGray2, progressColor: UIColor? = .systemBlue) {
        super.init(frame: frame)
        self.frame = frame
        self.horizontalMargin = horizontalMargin
        self.verticalMargin = verticalMargin
        self.ballRadius = ballRadius
        self.ballColor = ballColor
        self.lineColor = lineColor
        self.progressColor = progressColor
        
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        caculateUIFrame()
        
        didLayout = true
        
    }
    
    
    public func updateValue(value: CGFloat) {
        currentValue = value
        if !didLayout {
            initialValue = value
             return
         }
         let progress = (currentValue - minValue) / (maxValue - minValue)
         slideTo(x: horizontalMargin + (bounds.size.width - horizontalMargin * 2) * progress)
         
    }
    
    func setupUI() {
        backgroundColor = .white
        lineLayer.lineWidth = 5
        lineLayer.strokeColor = lineColor.cgColor
        lineLayer.lineCap = .round
        lineLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(lineLayer)
        
        progressLineLayer.lineWidth = 5
        progressLineLayer.strokeColor = progressColor.cgColor
        progressLineLayer.lineCap = .round
        progressLineLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(progressLineLayer)
        
        ball.backgroundColor = ballColor
        ball.layer.shadowColor = UIColor(white: 0, alpha: 0.3).cgColor
        ball.layer.shadowOffset = CGSize(width: 3, height: 1)
        ball.layer.shadowOpacity = 1
        addSubview(ball)
        
        panGes = UIPanGestureRecognizer(target: self, action: #selector(panGesChanged))
        ball.addGestureRecognizer(panGes)
        
        caculateUIFrame()

    }
    
    func caculateUIFrame() {
        
        let height = bounds.height - verticalMargin * 2
        let width = bounds.width - horizontalMargin * 2
        let halfWidth = width / 2
        
        // 计算圆弧圆点
        let radius = (height * height + halfWidth * halfWidth)/(2 * height)
        
        let cosResult = (radius - height)/radius
        
        let angle = acos(Double(cosResult))
        
        let startAngle = Double.pi * 3 / 2 - angle
        let endAngle = Double.pi * 3 / 2 + angle
        
        let path = UIBezierPath(arcCenter: CGPoint(x: bounds.width / CGFloat(2), y: verticalMargin + radius), radius: radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: true)
        lineLayer.path = path.cgPath
        
        self.startAngle = CGFloat(startAngle)
        self.endAngle = CGFloat(endAngle)
        self.totalAngle = CGFloat(angle)
        self.radius = radius
        self.centerPoint = CGPoint(x: bounds.width / CGFloat(2), y: verticalMargin + radius)

        ball.bounds = CGRect(x: 0, y: 0, width: ballRadius * 2, height: ballRadius * 2)
        ball.center = CGPoint(x: width + CGFloat(horizontalMargin), y: bounds.height - verticalMargin)
        
        ball.layer.cornerRadius = ballRadius
        
        let progress = (currentValue - minValue)/(maxValue - minValue)
        self.slideTo(x: self.horizontalMargin + progress * (bounds.width - horizontalMargin * CGFloat(2)))
    }
    
    @objc
    func panGesChanged() {
        
        if panGes.state == .began {
            startX = ball.center.x
        }
        
        if panGes.state == .changed {
            // 计算x值
            let transitionX = panGes.translation(in: self).x
            var x = transitionX + startX
//            var x = panGes.location(in: self).x
            if x < horizontalMargin {
                x = horizontalMargin
            }
            if x > bounds.width - horizontalMargin {
                x = bounds.width - horizontalMargin
            }
            slideTo(x: x)
        }
    }
    
    func slideTo(x: CGFloat) {
        let distance = x - (bounds.width)/2
        let sinResult = distance / radius
        let angle = asin(sinResult)
        let leftHeigth = cos(angle) * radius
        let height = radius - leftHeigth
        
        let y = verticalMargin + height

        // 根据弧度计算百分比
        var progress: CGFloat = 0
        if angle >= 0 {
            progress = 1 - ((self.totalAngle - angle)/self.totalAngle)/2
        } else {
            progress = ((self.totalAngle + angle)/self.totalAngle)/2
        }

        currentValue = (maxValue - minValue) * progress + minValue
        
        let progressLayerPath = UIBezierPath(arcCenter: CGPoint(x: bounds.width / CGFloat(2), y: verticalMargin + radius), radius: radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(startAngle + (endAngle - startAngle) * progress), clockwise: true)
        progressLineLayer.path = progressLayerPath.cgPath
        
        ball.center = CGPoint(x: x, y: y)
        
        valueDidChanged?(currentValue)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
