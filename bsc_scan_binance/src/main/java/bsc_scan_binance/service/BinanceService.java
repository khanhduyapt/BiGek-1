package bsc_scan_binance.service;

import java.util.List;

import bsc_scan_binance.entity.Orders;
import bsc_scan_binance.response.CandidateTokenCssResponse;

public interface BinanceService {

    List<CandidateTokenCssResponse> getList(Boolean isOrderByBynaceVolume);

    public void loadData(String gecko_id, String symbol);

    public void loadDataBtcVolumeDay(String gecko_id, String symbol);

    public void monitorProfit();

    public void monitorBollingerBandwidth();

    List<Orders> getOrderList();
}
