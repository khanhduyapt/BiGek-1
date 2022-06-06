package bsc_scan_geckko.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_geckko.entity.CandidateCoin;

@Repository
public interface CandidateCoinRepository extends JpaRepository<CandidateCoin, String> {
    public List<CandidateCoin> findAllByOrderByVolumnDivMarketcapDesc();
}
