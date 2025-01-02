//@version=5
indicator("MACD Histogram Peaks with Vertical Lines", overlay=true, max_bars_back=5000)

ma06 = ta.sma(close, 6)
ma10 = ta.sma(close,10)
ma20 = ta.sma(close,20)
ma50 = ta.sma(close,50)
plot (ma06, title = "MA6", color=color.gray)
plot (ma10, title = "MA10", color=color.red)
plot (ma20, title = "MA20", color=color.blue)
plot (ma50, title = "MA50", color=color.black)

// MACD calculation
[macdLine, signalLine, hist] = ta.macd(close, 12, 26, 9)

// Plot MACD, Signal, and Histogram
// plot(macdLine, color=color.black, title="MACD Line")
// plot(signalLine, color=color.red, title="Signal Line")
// histPlot = plot(hist, color=color.gray, style=plot.style_histogram, title="MACD Histogram")

// Function to draw vertical line at the given bar index
drawVerticalLine(barIdx, colorLine) =>
    line.new(x1=barIdx, y1=high + 10, x2=barIdx, y2=low - 10, xloc=xloc.bar_index, extend=extend.both, color=colorLine, style=line.style_dotted, width=1)

// Variables to track peaks and troughs
var int peakIndex = na
var int troughIndex = na
var bool lookingForPeak = true

// Maximum number of lines
maxLines = 5000

// Ensure that only 5000 bars are checked to avoid exceeding TradingView's limit
lookbackLimit = 5000
if (bar_index < lookbackLimit)
    // Look for peaks in histogram
    if (hist > 0 and lookingForPeak)
        if (na(peakIndex) or hist > hist[1])  // Check if current hist > previous hist
            peakIndex := bar_index
    if (hist <= 0 and not na(peakIndex))
        drawVerticalLine(peakIndex, color.red)  // Draw vertical line at peak with red color
        peakIndex := na
        lookingForPeak := false

    // Look for troughs in histogram
    if (hist < 0 and not lookingForPeak)
        if (na(troughIndex) or hist < hist[1])  // Check if current hist < previous hist
            troughIndex := bar_index
    if (hist >= 0 and not na(troughIndex))
        drawVerticalLine(troughIndex, color.blue)  // Draw vertical line at trough with blue color
        troughIndex := na
        lookingForPeak := true
//----------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------
normalize(_v) =>
    x = _v
    x := x - math.round(x)
    if x < 0
        x := x + 1
    x

calcPhase(_year, _month, _day) =>
    int y = na
    int m = na
    float k1 = na 
    float k2 = na 
    float k3 = na
    float jd = na
    float ip = na

    y := _year - math.round((12 - _month) / 10)       
    m := _month + 9
    if m >= 12 
        m := m - 12
    
    k1 := math.round(365.25 * (y + 4712))
    k2 := math.round(30.6 * m + 0.5)
    k3 := math.round(math.round((y / 100) + 49) * 0.75) - 38
    
    jd := k1 + k2 + _day + 59
    if jd > 2299160
        jd := jd - k3
    ip := normalize((jd - 2451550.1) / 29.530588853)
    age = ip * 29.53

age = calcPhase(year, month, dayofmonth)
moon =  math.round(age)[1] > math.round(age) ? 1 : math.round(age)[1] < 15 and math.round(age) >= 15 ? -1 : na
plotshape(
     moon==1, 
     "Full Moon", 
     shape.circle, 
     location.top, 
     color.new(color.blue,50), 
     size=size.tiny
     )   

plotshape(
     moon==-1, 
     "New Moon", 
     shape.circle, 
     location.bottom, 
     color.new(color.gray,10), 
     size=size.tiny
     )   
//----------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------