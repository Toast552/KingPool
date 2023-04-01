USING IBAPI

PUBLIC CLASS MyWrapper EXTENDS EWrapper
    INSTANCE nextOrderId AS NULL
    INSTANCE orderStatus AS Dictionary<INT, STRING> := Dictionary<INT, STRING>.NEW()
    INSTANCE historicalData AS List<BarData> := List<BarData>.NEW()

    METHOD nextValidId(orderId AS INT) OVERRIDE
        SUPER.nextValidId(orderId)
        SELF.nextOrderId := orderId

    METHOD orderStatus(orderId AS INT, status AS STRING, filled AS DOUBLE, remaining AS DOUBLE, avgFillPrice AS DOUBLE, permId AS INT, parentId AS INT, lastFillPrice AS DOUBLE, clientId AS INT, whyHeld AS STRING, mktCapPrice AS DOUBLE) OVERRIDE
        SELF.orderStatus[orderId] := status

    METHOD openOrder(orderId AS INT, contract AS Contract, order AS Order, orderState AS OrderState) OVERRIDE
        Console.WriteLine("Open Order: {0} {1} {2} {3} {4} {5} {6}", orderId, contract.symbol, contract.secType, order.action, order.orderType, order.totalQuantity, orderState.status)

    METHOD historicalData(reqId AS INT, bar AS BarData) OVERRIDE
        SELF.historicalData.ADD(bar)
END CLASS

FUNCTION createContract(symbol AS STRING, secType AS STRING, exchange AS STRING, currency AS STRING, expiry AS STRING := "", strike AS DOUBLE := 0, right AS STRING := "") AS Contract
    LOCAL contract AS Contract := Contract{}.NEW()
    contract.symbol := symbol
    contract.secType := secType
    contract.exchange := exchange
    contract.currency := currency
    contract.lastTradeDateOrContractMonth := expiry
    contract.strike := strike
    contract.right := right
    RETURN contract
END FUNCTION

FUNCTION createOrder(action AS STRING, quantity AS DOUBLE, orderType AS STRING, price AS DOUBLE) AS Order
    LOCAL order AS Order := Order{}.NEW()
    order.action := action
    order.orderType := orderType
    order.totalQuantity := quantity
    order.lmtPrice := price
    RETURN order
END FUNCTION

PROCEDURE placeOrder(orderId AS INT, contract AS Contract, order AS Order)
    LOCAL client AS EClient := EClient{}.NEW(MyWrapper{})
    client.placeOrder(orderId, contract, order)
END PROCEDURE

PROCEDURE cancelOrder(orderId AS INT)
    LOCAL client AS EClient := EClient{}.NEW(MyWrapper{})
    client.cancelOrder(orderId)
END PROCEDURE

PROCEDURE reqHistoricalData(reqId AS INT, contract AS Contract, endDateTime AS STRING, durationStr AS STRING, barSizeSetting AS STRING, whatToShow AS STRING, useRTH AS INT, formatDate AS INT := 2, keepUpToDate AS BOOLEAN := FALSE, chartOptions AS TagValueList := TagValueList{}.NEW())
    LOCAL client AS EClient := EClient{}.NEW(MyWrapper{})
    client.reqHistoricalData(reqId, contract, endDateTime, durationStr, barSizeSetting, whatToShow, useRTH, formatDate, keepUpToDate, chartOptions)
END PROCEDURE

FUNCTION Main() AS VOID
    LOCAL client AS EClient := EClient{}.NEW(MyWrapper{})
    client.connect("127.0.0.1", 7497, 0)

    // Create the contract for the option being traded
    LOCAL contract AS Contract := createContract("QQQ", "OPT", "SMART", "USD", "20230303", 400, "CALL")

    // Request historical data for the option
    reqHistoricalData(1, contract, "", "1 D", "5 mins", "TRA
