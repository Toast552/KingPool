const { EClient } = require('ib-api')
const { EWrapper } = require('ib-api')
const { Contract } = require('ib-api')
const { Order } = require('ib-api')
const { BarData } = require('ib-api')
const client = new EClient(new MyWrapper())

class MyWrapper extends EWrapper {
  constructor() {
    super()
    this.nextOrderId = null
    this.orderStatus = {}
    this.historicalData = []
  }

  nextValidId(orderId) {
    super.nextValidId(orderId)
    this.nextOrderId = orderId
  }

  orderStatus(orderId, status, filled, remaining, avgFillPrice, permId, parentId, lastFillPrice, clientId, whyHeld, mktCapPrice) {
    this.orderStatus[orderId] = status
  }

  openOrder(orderId, contract, order, orderState) {
    console.log("Open Order:", orderId, contract.symbol, contract.secType, order.action, order.orderType, order.totalQuantity, orderState.status)
  }

  historicalData(reqId, bar) {
    this.historicalData.push(bar)
  }
}

function createContract(symbol, secType, exchange, currency, expiry="", strike=0, right="") {
  const contract = new Contract()
  contract.symbol = symbol
  contract.secType = secType
  contract.exchange = exchange
  contract.currency = currency
  contract.lastTradeDateOrContractMonth = expiry
  contract.strike = strike
  contract.right = right
  return contract
}

function createOrder(action, quantity, orderType, price) {
  const order = new Order()
  order.action = action
  order.orderType = orderType
  order.totalQuantity = quantity
  order.lmtPrice = price
  return order
}

function placeOrder(orderId, contract, order) {
  client.placeOrder(orderId, contract, order)
}

function cancelOrder(orderId) {
  client.cancelOrder(orderId)
}

function reqHistoricalData(reqId, contract, endDateTime, durationStr, barSizeSetting, whatToShow, useRTH, formatDate=2, keepUpToDate=false, chartOptions=null) {
  client.reqHistoricalData(reqId, contract, endDateTime, durationStr, barSizeSetting, whatToShow, useRTH, formatDate, keepUpToDate, chartOptions)
}

async function main() {
  await client.connect("127.0.0.1", 7497, 0)

  // Create the contract for the option being traded
  const contract = createContract("QQQ", "OPT", "SMART", "USD", "20230303", 400, "CALL")

  // Request historical data for the option
  reqHistoricalData(1, contract, "", "1 D", "5 mins", "TRADES", 0)
}

main()
