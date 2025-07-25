import datetime
import enum
import json
import logging
import random
import re
import string
import pandas as pd
from websocket import create_connection
import requests
import json
import time
import os
import sys
import shutil

logger = logging.getLogger(__name__)


class Interval(enum.Enum):
    in_1_minute = "1"
    in_3_minute = "3"
    in_5_minute = "5"
    in_15_minute = "15"
    in_30_minute = "30"
    in_45_minute = "45"
    in_1_hour = "1H"
    in_2_hour = "2H"
    in_3_hour = "3H"
    in_4_hour = "4H"
    in_daily = "1D"
    in_weekly = "1W"
    in_monthly = "1M"


class TvDatafeed:
    __sign_in_url = 'https://www.tradingview.com/accounts/signin/'
    __search_url = 'https://symbol-search.tradingview.com/symbol_search/?text={}&hl=1&exchange={}&lang=en&type=&domain=production'
    __ws_headers = json.dumps({"Origin": "https://data.tradingview.com"})
    __signin_headers = {'Referer': 'https://www.tradingview.com'}
    __ws_timeout = 5

    def __init__(
        self,
        username: str = None,
        password: str = None,
    ) -> None:
        """Create TvDatafeed object

        Args:
            username (str, optional): tradingview username. Defaults to None.
            password (str, optional): tradingview password. Defaults to None.
        """

        self.ws_debug = False

        self.token = self.__auth(username, password)

        if self.token is None:
            self.token = "unauthorized_user_token"
            logger.warning(
                "you are using nologin method, data you access may be limited"
            )

        self.ws = None
        self.session = self.__generate_session()
        self.chart_session = self.__generate_chart_session()

    def __auth(self, username, password):

        if (username is None or password is None):
            token = None

        else:
            data = {"username": username,
                    "password": password,
                    "remember": "on"}
            try:
                response = requests.post(
                    url=self.__sign_in_url, data=data, headers=self.__signin_headers)
                token = response.json()['user']['auth_token']
            except Exception as e:
                logger.error('error while signin')
                token = None

        return token

    def __create_connection(self):
        logging.debug("creating websocket connection")
        self.ws = create_connection(
            "wss://data.tradingview.com/socket.io/websocket", headers=self.__ws_headers, timeout=self.__ws_timeout
        )

    @staticmethod
    def __filter_raw_message(text):
        try:
            found = re.search('"m":"(.+?)",', text).group(1)
            found2 = re.search('"p":(.+?"}"])}', text).group(1)

            return found, found2
        except AttributeError:
            logger.error("error in filter_raw_message")

    @staticmethod
    def __generate_session():
        stringLength = 12
        letters = string.ascii_lowercase
        random_string = "".join(random.choice(letters)
                                for i in range(stringLength))
        return "qs_" + random_string

    @staticmethod
    def __generate_chart_session():
        stringLength = 12
        letters = string.ascii_lowercase
        random_string = "".join(random.choice(letters)
                                for i in range(stringLength))
        return "cs_" + random_string

    @staticmethod
    def __prepend_header(st):
        return "~m~" + str(len(st)) + "~m~" + st

    @staticmethod
    def __construct_message(func, param_list):
        return json.dumps({"m": func, "p": param_list}, separators=(",", ":"))

    def __create_message(self, func, paramList):
        return self.__prepend_header(self.__construct_message(func, paramList))

    def __send_message(self, func, args):
        m = self.__create_message(func, args)
        if self.ws_debug:
            print(m)
        self.ws.send(m)

    @staticmethod
    def __create_df(raw_data, symbol):
        try:
            out = re.search(r'"s":\[(.+?)\}\]', raw_data).group(1)
            x = out.split(',{"')
            data = list()
            volume_data = True

            for xi in x:
                xi = re.split(r"\[|:|,|\]", xi)
                ts = datetime.datetime.fromtimestamp(float(xi[4]))

                row = [ts]

                for i in range(5, 10):

                    # skip converting volume data if does not exists
                    if not volume_data and i == 9:
                        row.append(0.1)
                        continue
                    try:
                        row.append(float(xi[i]))

                    except ValueError:
                        volume_data = False
                        row.append(0.1)
                        logger.debug('no volume data')

                data.append(row)

            data = pd.DataFrame(
                data, columns=["datetime", "open",
                               "high", "low", "close", "volume"]
            ).set_index("datetime")
            data.insert(0, "symbol", value=symbol)
            return data
        except AttributeError:
            logger.error("no data, please check the exchange and symbol")

    @staticmethod
    def __format_symbol(symbol, exchange, contract: int = None):

        if ":" in symbol:
            pass
        elif contract is None:
            symbol = f"{exchange}:{symbol}"

        elif isinstance(contract, int):
            symbol = f"{exchange}:{symbol}{contract}!"

        else:
            raise ValueError("not a valid contract")

        return symbol

    def get_hist(
        self,
        symbol: str,
        exchange: str = "NSE",
        interval: Interval = Interval.in_weekly,
        n_bars: int = 10,
        fut_contract: int = None,
        extended_session: bool = False,
    ) -> pd.DataFrame:
        """get historical data

        Args:
            symbol (str): symbol name
            exchange (str, optional): exchange, not required if symbol is in format EXCHANGE:SYMBOL. Defaults to None.
            interval (str, optional): chart interval. Defaults to 'D'.
            n_bars (int, optional): no of bars to download, max 5000. Defaults to 10.
            fut_contract (int, optional): None for cash, 1 for continuous current contract in front, 2 for continuous next contract in front . Defaults to None.
            extended_session (bool, optional): regular session if False, extended session if True, Defaults to False.

        Returns:
            pd.Dataframe: dataframe with sohlcv as columns
        """
        symbol = self.__format_symbol(
            symbol=symbol, exchange=exchange, contract=fut_contract
        )

        interval = interval.value

        self.__create_connection()

        self.__send_message("set_auth_token", [self.token])
        self.__send_message("chart_create_session", [self.chart_session, ""])
        self.__send_message("quote_create_session", [self.session])
        self.__send_message(
            "quote_set_fields",
            [
                self.session,
                "ch",
                "chp",
                "current_session",
                "description",
                "local_description",
                "language",
                "exchange",
                "fractional",
                "is_tradable",
                "lp",
                "lp_time",
                "minmov",
                "minmove2",
                "original_name",
                "pricescale",
                "pro_name",
                "short_name",
                "type",
                "update_mode",
                "volume",
                "currency_code",
                "rchp",
                "rtc",
            ],
        )

        self.__send_message(
            "quote_add_symbols", [self.session, symbol,
                                  {"flags": ["force_permission"]}]
        )
        self.__send_message("quote_fast_symbols", [self.session, symbol])

        self.__send_message(
            "resolve_symbol",
            [
                self.chart_session,
                "symbol_1",
                '={"symbol":"'
                + symbol
                + '","adjustment":"splits","session":'
                + ('"regular"' if not extended_session else '"extended"')
                + "}",
            ],
        )
        self.__send_message(
            "create_series",
            [self.chart_session, "s1", "s1", "symbol_1", interval, n_bars],
        )
        self.__send_message("switch_timezone", [
                            self.chart_session, "exchange"])

        raw_data = ""

        logger.debug(f"getting data for {symbol}...")
        while True:
            try:
                result = self.ws.recv()
                raw_data = raw_data + result + "\n"
            except Exception as e:
                logger.error(e)
                break

            if "series_completed" in result:
                break

        return self.__create_df(raw_data, symbol)

    def search_symbol(self, text: str, exchange: str = ''):
        url = self.__search_url.format(text, exchange)

        symbols_list = []
        try:
            resp = requests.get(url)

            symbols_list = json.loads(resp.text.replace(
                '</em>', '').replace('<em>', ''))
        except Exception as e:
            logger.error(e)

        return symbols_list

# Lưu symbols vào file JSON nếu file chưa tồn tại
def save_symbols_to_file_if_not_exist(file_name, symbols):
    if not os.path.exists(file_name):  # Kiểm tra nếu file chưa tồn tại
        with open(file_name, "w", encoding="utf-8") as file:
            json.dump(symbols, file, ensure_ascii=False, indent=4)
        print(f"Default symbols have been saved to {file_name}.")
    else:
        print(f"File {file_name} already exists. No action taken.")

# Tải symbols từ file JSON
def load_symbols_from_file(file_name):
    if os.path.exists(file_name):  # Kiểm tra nếu file tồn tại
        with open(file_name, "r", encoding="utf-8") as file:
            return json.load(file)
    else:
        print(f"File {file_name} does not exist. Returning an empty list.")
        return []

# function to copy files
def copy_files(source_folder, target_folder):
    if os.path.exists(target_folder):
        print(f"Copying files to {target_folder}...")
        for file_name in os.listdir(source_folder):
            source_file = os.path.join(source_folder, file_name)
            target_file = os.path.join(target_folder, file_name)
            if os.path.isfile(source_file):  # Only copy files, not subfolders
                shutil.copy(source_file, target_file)
                print(f"Copied: {source_file} -> {target_file}")
        print(f"All files copied to {target_folder}.")
    else:
        print(f"Target folder does not exist: {target_folder}")

if __name__ == "__main__":
    
    ea_output_folder_desktop_cty = r"C:\Users\Admin\AppData\Roaming\MetaQuotes\Terminal\53785E099C927DB68A545C249CDBCE06\MQL5\Files"
    ea_output_folder_thinkpad_x1 = r"C:\Users\DellE5270\AppData\Roaming\MetaQuotes\Terminal\53785E099C927DB68A545C249CDBCE06\MQL5\Files"
    ea_output_folder_c470 = r"C:\Users\Admin\AppData\Roaming\MetaQuotes\Terminal\37D62096151F7BC42432CE8CFF2333E3\MQL5\Files"

    output_folder = r"D:\01_Projects\BiGek\bsc_scan_binance\src\main\resources\MQL5\tvdatafeed\Files"
    file_name = r"D:\01_Projects\BiGek\bsc_scan_binance\src\main\resources\MQL5\tvdatafeed\symbols.json"
    ea_output_folder = ea_output_folder_desktop_cty

    if not os.path.exists(output_folder):
        print(f"Folder not exists: {output_folder}. Creating it...")
        #os.makedirs(output_folder)
        output_folder = r"C:\BiGek-1\bsc_scan_binance\src\main\resources\MQL5\tvdatafeed\Files"
        file_name = r"C:\BiGek-1\bsc_scan_binance\src\main\resources\MQL5\tvdatafeed\symbols.json"
        ea_output_folder = ea_output_folder_thinkpad_x1
        if not os.path.exists(output_folder):
        	output_folder = r"C:\Users\Admin\Desktop\BiGek-1\bsc_scan_binance\src\main\resources\MQL5\tvdatafeed\Files"
        	file_name = r"C:\Users\Admin\Desktop\BiGek-1\bsc_scan_binance\src\main\resources\MQL5\tvdatafeed\symbols.json"
        	ea_output_folder = ea_output_folder_c470

    # Danh sách các cặp tên sàn và mã cổ phiếu
    # default_symbols = [
    #     ("HOSE", "VNINDEX"),
    #     ("HOSE", "AGR"),
    #     ("HOSE", "VNM"),
    #     ("HOSE", "VHM"),
    #     ("HOSE", "VHC"),
    #     ("HOSE", "KDH"),
    #     ("HOSE", "DXG"),
    #     ("HOSE", "FPT"),
    #     ("HOSE", "HPG"),
    #     ("HOSE", "QCG")
    # ]
    # save_symbols_to_file_if_not_exist(file_name, default_symbols)
    symbols = load_symbols_from_file(file_name)

    logging.basicConfig(level=logging.DEBUG)
    tv = TvDatafeed()

    # Lấy tham số interval từ dòng lệnh
    if len(sys.argv) != 2:
        print("Usage: python main.py <interval>")
        print("Supported intervals: 1H, 4H, 1D, 1W")
        sys.exit(1)

    interval_input = sys.argv[1]

    # Map tham số thành giá trị của class Interval
    interval_mapping = {
        "m30": Interval.in_30_minute,
        "1H" : Interval.in_1_hour,
        "4H" : Interval.in_4_hour,
        "1D" : Interval.in_daily,
        "1W" : Interval.in_weekly,
        "1M" : Interval.in_monthly
    }
    interval_naming = {
        "m30": "MINUTE30",
        "1H" : "1HOUR",
        "4H" : "4HOURS",
        "1D" : "DAILY",
        "1W" : "WEEKLY",
        "1M" : "MONTHLY"
    }
    if interval_input not in interval_mapping:
        print(f"Invalid interval '{interval_input}'. Supported intervals: m30, 1H, 4H, 1D, 1W")
        sys.exit(1)

    selected_interval = interval_mapping[interval_input]

    n_bars = 55
    if selected_interval == Interval.in_30_minute:
        n_bars = 270
    elif selected_interval in [Interval.in_1_hour, Interval.in_4_hour, Interval.in_daily, Interval.in_weekly]:
        n_bars = 65

    error_log_path = "invalid_symbols.txt"  # Tên file ghi symbol lỗi
    # Mở file ở chế độ ghi để xóa nội dung cũ
    # with open(error_log_path, 'w') as f:
    #     pass  # Chỉ để xóa nội dung

    # Lặp qua từng cặp tên sàn và mã cổ phiếu
    for market, symbol in symbols:
        print(f"Fetching data for {market}:{symbol} with interval {selected_interval.value}...")
        # Lấy dữ liệu
        data = tv.get_hist(symbol, market, interval=selected_interval, n_bars=n_bars, extended_session=False)

        # Kiểm tra dữ liệu có phải DataFrame không
        if isinstance(data, pd.DataFrame):
            # Tạo tên file dựa trên mã cổ phiếu và interval
            filename = os.path.join(output_folder, f"{market}_{symbol}_{interval_naming[interval_input]}.txt")
            
            # Lưu dữ liệu vào file với định dạng tab-separated
            if len(data) > 10:
                data.to_csv(filename, sep='\t', index=True)
                print(f"Data has been saved to {filename}")
            else:
                print(f"Data for {market}:{symbol} has less than 10 rows, skipping save to {filename}.")
        else:
            print(f"The data for {symbol} with interval {selected_interval.value} is not a DataFrame.")
            # Ghi symbol lỗi vào file log
            # with open(error_log_path, 'a') as f:
            #     f.write(f"{market}:{symbol}    https://www.tradingview.com/chart/r46Q5U5a/?interval=M&symbol={market}:{symbol}\n")

        # Nghỉ 30 giây giữa các lần gọi để tránh bị từ chối dịch vụ
        # print("Resting for 10 seconds...")
        # time.sleep(10)

    # Copy files to ThinkPad X1 folder if it exists
    copy_files(output_folder, ea_output_folder)
