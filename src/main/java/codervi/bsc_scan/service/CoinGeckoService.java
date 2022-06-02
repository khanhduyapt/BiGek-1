package codervi.bsc_scan.service;

import java.util.List;

import codervi.bsc_scan.entity.CandidateCoin;

public interface CoinGeckoService {

    public List<CandidateCoin> initCandidateCoin();

    public List<CandidateCoin> getList();

    public CandidateCoin loadData(String gecko_id, boolean is_get_new);
}
