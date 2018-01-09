import UIKit
import Neon
import DateToolsSwift

public protocol TimelineViewDelegate: class {
  func timelineView(_ timelineView: TimelineView, didLongPressAt hour: Int)
}

public class TimelineView: UIView {

  public weak var delegate: TimelineViewDelegate?

  public var date = Date() {
    didSet {
      setNeedsLayout()
    }
  }

  var currentTime: Date {
    return Date()
  }

  var style = TimelineStyle()

  var verticalDiff: CGFloat = 50
  var verticalInset: CGFloat = 10
  var leftInset: CGFloat = 53

  var horizontalEventInset: CGFloat = 3

  public var fullHeight: CGFloat {
    return verticalInset * 2 + verticalDiff * 24
  }

  var calendarWidth: CGFloat {
    return bounds.width - leftInset
  }
    
  var is24hClock = true {
    didSet {
      setNeedsDisplay()
    }
  }

  init() {
    super.init(frame: .zero)
    frame.size.height = fullHeight
    configure()
  }

  var times: [String] {
    return is24hClock ? _24hTimes : _12hTimes
  }

  fileprivate lazy var _12hTimes: [String] = Generator.timeStrings12H()
  fileprivate lazy var _24hTimes: [String] = Generator.timeStrings24H()
  
  fileprivate lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))

  var isToday: Bool {
    return date.isToday
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    contentScaleFactor = 1
    layer.contentsScale = 1
    contentMode = .redraw
    backgroundColor = .white
    
    // Add long press gesture recognizer
    addGestureRecognizer(longPressGestureRecognizer)
  }
  
  @objc func longPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
    if (gestureRecognizer.state == .began) {
      // Get timeslot of gesture location
      let pressedLocation = gestureRecognizer.location(in: self)
      let percentOfHeight = (pressedLocation.y - verticalInset) / (bounds.height - (verticalInset * 2))
      let pressedAtHour: Int = Int(24 * percentOfHeight)
      delegate?.timelineView(self, didLongPressAt: pressedAtHour)
    }
  }

  public func updateStyle(_ newStyle: TimelineStyle) {
    style = newStyle.copy() as! TimelineStyle
    
    switch style.dateStyle {
      case .twelveHour:
        is24hClock = false
        break
      case .twentyFourHour:
        is24hClock = true
        break
      default:
        is24hClock = Locale.autoupdatingCurrent.uses24hClock()
        break
    }
    
    backgroundColor = style.backgroundColor
    setNeedsDisplay()
  }

  override public func draw(_ rect: CGRect) {
    super.draw(rect)

    var hourToRemoveIndex = -1

    if isToday {
      let minute = currentTime.minute
      if minute > 39 {
        hourToRemoveIndex = currentTime.hour + 1
      } else if minute < 21 {
        hourToRemoveIndex = currentTime.hour
      }
    }

    let mutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
    mutableParagraphStyle.lineBreakMode = .byWordWrapping
    mutableParagraphStyle.alignment = .right
    let paragraphStyle = mutableParagraphStyle.copy() as! NSParagraphStyle
    
    let attributes = [NSAttributedStringKey.paragraphStyle: paragraphStyle,
                      NSAttributedStringKey.foregroundColor: self.style.timeColor,
                      NSAttributedStringKey.font: style.font] as [NSAttributedStringKey : Any]

    for (i, time) in times.enumerated() {
      let iFloat = CGFloat(i)
      let context = UIGraphicsGetCurrentContext()
      context!.interpolationQuality = .none
      context?.saveGState()
      context?.setStrokeColor(self.style.lineColor.cgColor)
      context?.setLineWidth(onePixel)
      context?.translateBy(x: 0, y: 0.5)
      let x: CGFloat = 53
      let y = verticalInset + iFloat * verticalDiff
      context?.beginPath()
      context?.move(to: CGPoint(x: x, y: y))
      context?.addLine(to: CGPoint(x: (bounds).width, y: y))
      context?.strokePath()
      context?.restoreGState()

      if i == hourToRemoveIndex { continue }
        
      let fontSize = style.font.pointSize
      let timeRect = CGRect(x: 2, y: iFloat * verticalDiff + verticalInset - 7,
                            width: leftInset - 8, height: fontSize + 2)

      let timeString = NSString(string: time)

      timeString.draw(in: timeRect, withAttributes: attributes)
    }
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    
  }

  // MARK: - Helpers

  fileprivate var onePixel: CGFloat {
    return 1 / UIScreen.main.scale
  }

  fileprivate func dateToY(_ date: Date) -> CGFloat {
    if date.dateOnly() > self.date.dateOnly() {
      // Event ending the next day
      return 24 * verticalDiff + verticalInset
    } else if date.dateOnly() < self.date.dateOnly() {
      // Event starting the previous day
      return verticalInset
    } else {
      let hourY = CGFloat(date.hour) * verticalDiff + verticalInset
      let minuteY = CGFloat(date.minute) * verticalDiff / 60
      return hourY + minuteY
    }
  }
    
    func timeToY(_ date: Date) -> CGFloat {
        let hourY = CGFloat(date.hour) * verticalDiff + verticalInset
        let minuteY = CGFloat(date.minute) * verticalDiff / 60
        return hourY + minuteY
    }
    
    private func yToTimeNumber(_ y: CGFloat) -> (Int, Int) {
        let timeY = y - verticalInset
        let h = Int(timeY / verticalDiff)
        let mY = timeY - CGFloat(h) * verticalDiff
        let m = Int(mY * 60 / verticalDiff)
        
        return (h, m)
    }
    
//    func yToTime(_ y: CGFloat) -> Date {
//        let timeY = y - verticalInset
//        let h = Int(timeY / verticalDiff)
//        let mY = timeY - CGFloat(h) * verticalDiff
//        let m = Int(mY * 60 / verticalDiff)
//        
//        var dateComponents = DateComponents()
//        dateComponents.timeZone = Calendar.current.timeZone
//        dateComponents.hour = h
//        dateComponents.minute = m
//        
//        let userCalendar = Calendar.current
//        return userCalendar.date(from: dateComponents) ?? Date()
//    }
    
    var validY: (above: CGFloat, below: CGFloat) {
        let above = verticalInset
        let below = verticalInset + 24 * verticalDiff
        return (above, below)
    }
    
    func normalizeY(_ y: CGFloat) -> (CGFloat, Date) {
        var (h, m) = yToTimeNumber(y)
        if m > 45 {
            m = 0
            h += 1
        } else if m > 15 {
            m = 30
        } else {
            m = 0
        }
        
        var dateComponents = DateComponents()
        dateComponents.timeZone = Calendar.current.timeZone
        dateComponents.hour = h
        dateComponents.minute = m
        
        let userCalendar = Calendar.current
        let dateNormalized = userCalendar.date(from: dateComponents) ?? Date()
        let yNormalized = timeToY(dateNormalized)
        
        return (yNormalized, dateNormalized)
    }
}
