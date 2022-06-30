package bsc_scan_binance.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.BollArea;

@Repository
public interface BollAreaRepository extends JpaRepository<BollArea, String> {

    @Query(value = "SELECT m.* FROM boll_area m WHERE m.is_bottom_area and m.profit > 5 Order By m.profit DESC", nativeQuery = true)
    public List<BollArea> findBottomArea();
}
