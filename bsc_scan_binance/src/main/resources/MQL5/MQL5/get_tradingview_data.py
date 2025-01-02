# from playwright.sync_api import sync_playwright

# chrome_path = r'C:\Program Files\Google\Chrome\Application\chrome.exe'
# chromium_path = r'C:\Users\Admin\AppData\Local\ms-playwright\chromium-1140\chrome-win\chrome.exe'

# def test_playwright():
#     try:
#         with sync_playwright() as p:
#             browser = p.chromium.launch(
#                 headless=False,  # Chạy trình duyệt hiển thị
#                 executable_path=chromium_path
#             )
#             page = browser.new_page()
#             page.set_extra_http_headers({
#                 "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"
#             })
#             page.goto("https://www.tradingview.com/chart/?interval=W&symbol=HOSE:QCG", timeout=120000, wait_until="load")
#             print(page.title())  # In tiêu đề trang
#             browser.close()  # Đóng trình duyệt sau khi sử dụng
#     except Exception as e:
#         print(f"Error: {e}")

# test_playwright()

from playwright.sync_api import sync_playwright
import time

chrome_path = r'C:\Program Files\Google\Chrome\Application\chrome.exe'
chromium_path = r'C:\Users\Admin\AppData\Local\ms-playwright\chromium-1140\chrome-win\chrome.exe'

def get_data_from_tradingview():
    try:
        with sync_playwright() as p:
            browser = p.chromium.launch(
                headless=False,  # Chạy trình duyệt hiển thị
                executable_path=chromium_path
            )
            page = browser.new_page()
            page.set_extra_http_headers({
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"
            })
            page.goto("https://www.tradingview.com/chart/?interval=W&symbol=HOSE:QCG", timeout=120000, wait_until="load")
            
            print("Page title:", page.title())  # In tiêu đề trang
            time.sleep(5)  # Đợi trang tải xong

            # In ra DOM để kiểm tra các phần tử chứa dữ liệu
            print(page.content())  # Hoặc dùng page.query_selector_all để kiểm tra phần tử cụ thể
            
            # Lấy dữ liệu nến từ TradingView (lý thuyết, tùy vào DOM)
            candles = page.query_selector_all(".tv-widget-candlestick-plot")
            
            data = []
            for candle in candles[:20]:  # Lấy 20 nến tuần đầu
                time_stamp = candle.query_selector(".tv-widget-candlestick-time")
                open_price = candle.query_selector(".tv-widget-candlestick-open")
                high_price = candle.query_selector(".tv-widget-candlestick-high")
                low_price = candle.query_selector(".tv-widget-candlestick-low")
                close_price = candle.query_selector(".tv-widget-candlestick-close")
                
                if time_stamp and open_price and high_price and low_price and close_price:
                    # Đưa dữ liệu vào list
                    data.append([
                        time_stamp.inner_text(),
                        open_price.inner_text(),
                        high_price.inner_text(),
                        low_price.inner_text(),
                        close_price.inner_text()
                    ])
            
            # Kiểm tra xem dữ liệu đã có chưa
            if data:
                # Lưu dữ liệu vào output.txt
                with open('output.txt', mode='w') as file:
                    file.write("Timestamp, Open, High, Low, Close\n")  # Header
                    for row in data:
                        file.write(f"{row[0]}, {row[1]}, {row[2]}, {row[3]}, {row[4]}\n")

                print("Data saved to output.txt")
            else:
                print("No data found")

            browser.close()  # Đóng trình duyệt sau khi sử dụng
    except Exception as e:
        print(f"Error: {e}")

get_data_from_tradingview()
