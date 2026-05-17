import requests
import pandas as pd

def fetch_bitget_price(symbol = "BICUSDT"):
    url = f"https://api.bitget.com/api/v2/spot/market/tickers?symbol={symbol}"
    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()

        ticker_list = data.get('data',[]) # the data is inside the 'data' key as a list
        df = pd.DataFrame(ticker_list)
        return df[['symbol','lastPr','high24h','low24h','ts']]
    
    else:
        return "Error fetching data"
    

print(fetch_bitget_price("BTCUSDT"))