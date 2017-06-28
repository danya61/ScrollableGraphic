import UIKit

class Graphic: UIView {
	
	/// Высота графика, включая Лэйблы
	
	fileprivate let graphViewHeight: CGFloat = 370
	
	/// Полная ширина графика
	
	fileprivate let graphViewWidth = UIScreen.main.bounds.width - 10
	
	/// Ширина полотна с цветами
	
	fileprivate let colorsViewWidth: CGFloat = 12
	
	/// Значения графика
	
	fileprivate var graphicValues: [String] = []
	
	/// Количество одновременно видимых точек на экране
	
	fileprivate let pointOnScreenCount = 5
	
	/// Интервал между двумя точками на графике
	
	fileprivate var intervalBetweenTwoPoints: CGFloat {
		return (graphViewWidth - CGFloat(colorsViewWidth)) / CGFloat(pointOnScreenCount)
	}
	
	/// Отступ от края
	fileprivate var spaceFromBoard: CGFloat {
		return intervalBetweenTwoPoints / 2.0
	}
	
	/// Высота Лэйблов "Значения данных" и "Даты"
	
	fileprivate var labelHeight: CGFloat  {
		return CGFloat(graphViewHeight / 8)
	}
	
	/// Реальная высота графика
	
	fileprivate var realGraphicViewHeight: CGFloat {
		return graphViewHeight - labelHeight * 2
	}
	
	/// Реальная ширина графика
	
	fileprivate var realGraphicViewWidth: CGFloat {
		return graphViewWidth - colorsViewWidth
	}
	
	///Scroll view
	
	fileprivate var scrollView = UIScrollView()
	
	///Content view с точками, соеиненными линиями
	
	fileprivate var contentView: UIView = UIView()
	
	///Массив позиций значений в Rang'e
	
	fileprivate var rangePosition: [Int] = []
	
	///Цвет линии
	
	fileprivate lazy var lineColor: UIColor = {
		return .black
	}()
	
	///Массив дат
	
	fileprivate var datesList: [Date] = []
	
	
	///Индекс текцщего параметра в массиве параметров
	
	fileprivate var currentIndex: Int?
	
	init(dates: [Date],
	     graphsValues: [String],
	     colorList: [UIColor],
	     ranges: [Int],
	     currentIndex: Int) {
		super.init(frame: CGRect(x: 0, y: 0, width: Int(graphViewWidth), height: Int(graphViewHeight)))
		self.graphicValues = graphsValues
		self.rangePosition = ranges
		self.datesList = dates
		self.currentIndex = currentIndex
		self.drawColorfulLine(colorList: colorList)
		self.scrollView.delegate = self
		self.initializeScrollView(colorList: colorList)
		self.resetPointsAndLines(colorList: colorList)
		self.backgroundColor = .white
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func drawColorfulLine(colorList: [UIColor]) {
		let lineView = UIView(frame: CGRect(x: 0,
		                                    y: labelHeight,
		                                    width: colorsViewWidth,
		                                    height: realGraphicViewHeight))
		let oneLineHeight = realGraphicViewHeight / CGFloat(colorList.count)
		var startPoint = CGPoint(x: 0, y: 0)
		var endPoint = CGPoint(x: 0, y: oneLineHeight)
		for i in 0...colorList.count - 1 {
			let path = UIBezierPath()
			path.move(to: startPoint)
			path.addLine(to: endPoint)
			startPoint = CGPoint(x: 0, y: endPoint.y + 0.02)
			endPoint = CGPoint(x: 0, y: startPoint.y + oneLineHeight)
			let shapeLayer = CAShapeLayer()
			shapeLayer.path = path.cgPath
			shapeLayer.strokeColor = colorList[i].cgColor
			shapeLayer.lineWidth = self.colorsViewWidth
			lineView.layer.addSublayer(shapeLayer)
		}
		self.addSubview(lineView)
	}
	
	func resetPointsAndLines( colorList: [UIColor]) {
		let contentSizeRect = CGRect(x: 0,
		                             y: labelHeight,
		                             width: scrollView.contentSize.width,
		                             height: realGraphicViewHeight)
		contentView.frame = contentSizeRect
		contentView.backgroundColor = .clear
		var previousPoint: CGPoint?
		var currentPoint: CGPoint?
		var centerPointArray: [CGPoint] = []
		guard !graphicValues.isEmpty else {
			return 
		}
		for index in 0...graphicValues.count - 1 {
			let pointCenterPosition = getValuePosition(numberOfValue: index, colorCount: colorList.count)
			centerPointArray.append(pointCenterPosition)
			switch index {
			case 0:
				currentPoint = pointCenterPosition
			default:
				previousPoint = currentPoint
				currentPoint = pointCenterPosition
				self.drawLineBetweenTwoPoints(point1: previousPoint!, point2: currentPoint!)
			}
		}
		for (index, points) in centerPointArray.enumerated() {
			self.drawCirclesOnGraphic(centerPoint: points, colorList: colorList, index: index)
		}
		
		self.scrollView.addSubview(contentView)
	}
	
	
	///Рисует точки
	func drawCirclesOnGraphic(centerPoint: CGPoint, colorList: [UIColor], index: Int) {
		let linePath = UIBezierPath()
		linePath.move(to: CGPoint(x: centerPoint.x, y: realGraphicViewHeight))
		linePath.addLine(to: centerPoint)
		let shapeLayerLine = CAShapeLayer()
		shapeLayerLine.path = linePath.cgPath
		shapeLayerLine.strokeColor = UIColor(red: 239 / 255,
		                                     green: 239 / 255,
		                                     blue: 239 / 255,
		                                     alpha: 1).cgColor
		shapeLayerLine.lineWidth = 0.883
		contentView.layer.addSublayer(shapeLayerLine)
		let circlePath =  UIBezierPath(arcCenter: centerPoint,
		                               radius: CGFloat(6.243),
		                               startAngle: CGFloat(0),
		                               endAngle:CGFloat(Double.pi * 2),
		                               clockwise: true)
		let shapeLayer = CAShapeLayer()
		shapeLayer.path = circlePath.cgPath
		let currentColor = colorList[rangePosition[index]].cgColor
		shapeLayer.fillColor = currentColor
		shapeLayer.strokeColor = rangePosition[index] % 2 == 1 ?  UIColor.white.cgColor : UIColor(red: 239 / 255,
		                                                                                          green: 239 / 255,
		                                                                                          blue: 239 / 255,
		                                                                                          alpha: 1).cgColor
		shapeLayer.lineWidth = 3.11
		contentView.layer.addSublayer(shapeLayer)
		guard let curIndex = self.currentIndex else {
			return
		}
		if index == curIndex {
			let outsideCirclePath = UIBezierPath(arcCenter: centerPoint,
			                           radius: CGFloat(9.843),
			                           startAngle: CGFloat(0),
			                           endAngle:CGFloat(Double.pi * 2),
			                           clockwise: true)
			let outsideShapeLayer = CAShapeLayer()
			outsideShapeLayer.path = outsideCirclePath.cgPath
			outsideShapeLayer.fillColor = UIColor.clear.cgColor
			outsideShapeLayer.strokeColor = currentColor
			outsideShapeLayer.lineWidth = 4.012
			contentView.layer.addSublayer(outsideShapeLayer)
		}
		self.setLabels(centerPoint: centerPoint, index: index)
	}
	
	func setLabels(centerPoint: CGPoint, index: Int) {
		let valueFrame = CGRect(x: centerPoint.x - intervalBetweenTwoPoints / 3 ,
		                        y: labelHeight / 4,
		                        width: intervalBetweenTwoPoints / 2 ,
		                        height: labelHeight - 0.102)
		let valueLabel = UILabel(frame: valueFrame)
		valueLabel.textAlignment = .center
		valueLabel.adjustsFontSizeToFitWidth = true
		valueLabel.font = UIFont.italicSystemFont(ofSize: 11)
		guard let curIndex = self.currentIndex else {
			return
		}
		if curIndex != index {
			valueLabel.textColor = UIColor(colorLiteralRed: 133 / 255,
			                               green: 133 / 255,
			                               blue:  133 / 255,
			                               alpha: 1)
		} else {
			valueLabel.textColor = UIColor(colorLiteralRed: 242 / 255,
			                               green: 100 / 255,
			                               blue:  100 / 255,
			                               alpha: 1)
		}
		valueLabel.text = graphicValues[index]
		self.scrollView.addSubview(valueLabel)
		let dateFrame = CGRect(x: centerPoint.x - intervalBetweenTwoPoints / 2,
		                       y: graphViewHeight - labelHeight + 0.102,
		                       width: intervalBetweenTwoPoints,
		                       height: labelHeight - 0.102)
		let dateLabel = UILabel(frame: dateFrame)
		dateLabel.textAlignment = .center
		dateLabel.numberOfLines = 2
		if curIndex != index {
			dateLabel.textColor = UIColor(colorLiteralRed: 133 / 255,
			                              green: 133 / 255,
			                              blue:  133 / 255,
			                              alpha: 1)
		} else {
			dateLabel.textColor = UIColor.black.withAlphaComponent(0.955)
		}
		dateLabel.font = UIFont.italicSystemFont(ofSize: 11)
		var currentDate = datesList[index]
		let formatter = DateFormatter()
		formatter.dateFormat = "dd MMMM HH:mm"
		let stringDate = formatter.string(from: currentDate)
		dateLabel.text = stringDate
		self.scrollView.addSubview(dateLabel)
	}
	
	///Рисует линию между двумя точками
	func drawLineBetweenTwoPoints(point1: CGPoint, point2: CGPoint) {
		let path = UIBezierPath()
		path.move(to: point1)
		path.addLine(to: point2)
		let shapeLayer = CAShapeLayer()
		shapeLayer.path = path.cgPath
		shapeLayer.strokeColor = self.lineColor.cgColor
		shapeLayer.lineWidth = 3.98
		contentView.layer.addSublayer(shapeLayer)
	}
	
	/// Получает позицию точки на системе координат
	func getValuePosition(numberOfValue: Int, colorCount: Int) -> CGPoint {
		let oneColumnHeight = realGraphicViewHeight / CGFloat(colorCount)
		let pointRange = rangePosition[numberOfValue]
		let pointY =  CGFloat(pointRange) * oneColumnHeight + (oneColumnHeight / 2)
		let pointX = spaceFromBoard + CGFloat(numberOfValue) * intervalBetweenTwoPoints
		return CGPoint(x: pointX, y: pointY)
	}
	
}

extension Graphic: UIScrollViewDelegate {
	
	/// Инициализуем scroll view и его content mode
	
	func initializeScrollView(colorList: [UIColor]) {
		scrollView.frame = CGRect(x: colorsViewWidth,
		                          y: 0,
		                          width: realGraphicViewWidth,
		                          height: graphViewHeight)
		let scrollViewWidth = intervalBetweenTwoPoints * CGFloat(self.graphicValues.count) < realGraphicViewWidth ?
										realGraphicViewWidth : intervalBetweenTwoPoints * CGFloat(self.graphicValues.count)
		scrollView.contentSize = CGSize(width: scrollViewWidth,
		                                height: graphViewHeight)
		initializeBackgroundOfScrollView(colorList: colorList)
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.showsVerticalScrollIndicator = false
		guard let curIndex = self.currentIndex else {
			return
		}
		//Смотрим, куда нам скролить график, чтобы он был на нынешней точке
		if graphicValues.count >  pointOnScreenCount {
			let scrollCenterPoint: CGPoint?
			switch curIndex {
			case 0...Int(pointOnScreenCount / 2):
				scrollCenterPoint = CGPoint(x: 0,
																				y: 0)
			case (graphicValues.count - Int(pointOnScreenCount / 2))...graphicValues.count - 1:
				scrollCenterPoint = CGPoint(x: intervalBetweenTwoPoints * CGFloat(curIndex) - intervalBetweenTwoPoints * CGFloat(pointOnScreenCount - 1),
																				y: 0)
			default:
				scrollCenterPoint = CGPoint(x: intervalBetweenTwoPoints * CGFloat(curIndex) - intervalBetweenTwoPoints * CGFloat(pointOnScreenCount / 2),
																				y: 0)
			}
			scrollView.setContentOffset(scrollCenterPoint!,
			                            animated: true)
		}
		self.addSubview(scrollView)
	}
	
	
	/// инициализируем фон графика
	func initializeBackgroundOfScrollView(colorList: [UIColor]) {
		let scrollWidth = scrollView.contentSize.width
		let oneLineHeight = realGraphicViewHeight / CGFloat(colorList.count)
		for index in 0...colorList.count {
			let temporarityRect = CGRect(x: 0,
			                             y: CGFloat(index) * oneLineHeight + labelHeight,
			                             width: scrollWidth,
			                             height: oneLineHeight)
			let backgroundView = UIView(frame: temporarityRect)
			if index % 2 == 0 {
				backgroundView.backgroundColor = UIColor(red: 239 / 255,
				                                         green: 239 / 255,
				                                         blue: 239 / 255,
				                                         alpha: 0.442)
			} else {
				backgroundView.backgroundColor = UIColor.white
			}
			self.scrollView.addSubview(backgroundView)
		}
	}
	
}


