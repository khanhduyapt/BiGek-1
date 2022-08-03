package bsc_scan_token.service;

import java.util.List;

import bsc_scan_token.entity.CandidateCoin;

public interface CoinGeckoService {
    public List<CandidateCoin> initCandidateCoin();

    public List<CandidateCoin> getList();

    public CandidateCoin loadData(String gecko_id);

    public void hide(String gecko_id, String note);
}
