package bsc_scan_binance.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.OrderKey;
import bsc_scan_binance.entity.Orders;

@Repository
public interface OrdersRepository extends JpaRepository<Orders, OrderKey> {

    List<Orders> findAllByIdGeckoid(String geckoid);
}
