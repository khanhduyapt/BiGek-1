package bsc_scan_binance.repository;

import java.math.BigInteger;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.DepthBids;

@Repository
public interface DepthBidsRepository extends JpaRepository<DepthBids, BigInteger> {
    List<DepthBids> findAllByRowidxGreaterThan(BigInteger rowidx);
}
