from ibapi.client import EClient
from ibapi.wrapper import EWrapper
from ibapi.contract import Contract
from ibapi.order import Order
from ibapi.common import BarData
import time

class MyWrapper(EWrapper):
    def __init__(self):
        self.nextOrderId = None
        self.orderStatus = {}
        self.historicalData = []

    def nextValidId(self, orderId:int):
        super().nextValidId(orderId)
        self.nextOrderId = orderId

    def orderStatus(self, orderId:int, status:str, filled:float, remaining:float, avgFillPrice:float, permId:int, parentId:int, lastFillPrice:float, clientId:int, whyHeld:str, mktCapPrice:float):
        self.orderStatus[orderId] = status

    def openOrder(self, orderId:int, contract:Contract, order:Order, orderState):
        print("Open Order:", orderId, contract.symbol, contract.secType, order.action, order.orderType, order.totalQuantity, orderState.status)

    def historicalData(self, reqId:int, bar:BarData):
        self.historicalData.append(bar)

class MyClient(EClient):
    def __init__(self, wrapper):
        EClient.__init__(self, wrapper)

    def createContract(self, symbol, secType, exchange, currency, expiry="", strike=0, right=""):
        contract = Contract()
        contract.symbol = symbol
        contract.secType = secType
        contract.exchange = exchange
        contract.currency = currency
        contract.lastTradeDateOrContractMonth = expiry
        contract.strike = strike
        contract.right = right
        return contract

    def createOrder(self, action, quantity, orderType, price):
        order = Order()
        order.action = action
        order.orderType = orderType
        order.totalQuantity = quantity
        order.lmtPrice = price
        return order

    def placeOrder(self, orderId, contract, order):
        self.placeOrder(orderId, contract, order)

    def cancelOrder(self, orderId):
        self.cancelOrder(orderId)

    def reqHistoricalData(self, reqId, contract, endDateTime, durationStr, barSizeSetting, whatToShow, useRTH, formatDate=2, keepUpToDate=False, chartOptions=None):
        self.reqHistoricalData(reqId, contract, endDateTime, durationStr, barSizeSetting, whatToShow, useRTH, formatDate, keepUpToDate, chartOptions)

def main():
    wrapper = MyWrapper()
    client = MyClient(wrapper)
    client.connect("127.0.0.1", 7497, 0)

    # Create the contract for the option being traded
    contract = client.createContract("TSLA", "OPT", "SMART", "USD", "20230303", 800, "CALL")

    # Request historical data for the option
    client.reqHistoricalData(1, contract, "", "1 D", "5 mins", "TRADES", 0)

if __name__ == "__main__":
    main()
