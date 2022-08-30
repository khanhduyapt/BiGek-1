package bsc_scan_binance.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.DepthAsks;
import bsc_scan_binance.entity.DepthKey;

@Repository
public interface DepthAsksRepository extends JpaRepository<DepthAsks, DepthKey> {

}
