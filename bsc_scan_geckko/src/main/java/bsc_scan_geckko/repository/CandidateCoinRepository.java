package bsc_scan_geckko.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import bsc_scan_geckko.entity.CandidateCoin;

@Repository
public interface CandidateCoinRepository extends JpaRepository<CandidateCoin, String> {

    @Query(value = "SELECT m.* FROM candidate_coin m WHERE m.gecko_id IN (select gecko_id from binance_futures)", nativeQuery = true)
    public List<CandidateCoin> findAllByOrderByVolumnDivMarketcapDesc();
}
