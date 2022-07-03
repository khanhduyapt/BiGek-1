package bsc_scan_binance.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.PrepareOrders;

@Repository
public interface PrepareOrdersRepository extends JpaRepository<PrepareOrders, String> {
    List<PrepareOrders> findAllByDataType(String dataType);
}