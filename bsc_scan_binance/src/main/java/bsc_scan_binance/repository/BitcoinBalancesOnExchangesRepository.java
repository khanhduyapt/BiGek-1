package bsc_scan_binance.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.BitcoinBalancesOnExchanges;
import bsc_scan_binance.entity.BitcoinBalancesOnExchangesKey;

@Repository
public interface BitcoinBalancesOnExchangesRepository
        extends JpaRepository<BitcoinBalancesOnExchanges, BitcoinBalancesOnExchangesKey> {
}