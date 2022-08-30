package bsc_scan_binance.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.DepthBids;
import bsc_scan_binance.entity.DepthKey;

@Repository
public interface DepthBidsRepository extends JpaRepository<DepthBids, DepthKey> {

}
