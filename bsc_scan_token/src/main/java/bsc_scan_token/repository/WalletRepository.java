package bsc_scan_token.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_token.entity.Wallet;
import bsc_scan_token.entity.WalletKey;

@Repository
public interface WalletRepository extends JpaRepository<Wallet, WalletKey> {
    List<Wallet> findAllByIdGeckoid(String geckoid);
}
