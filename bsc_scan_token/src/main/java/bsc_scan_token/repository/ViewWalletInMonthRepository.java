package bsc_scan_token.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_token.entity.ViewWalletInMonth;
import bsc_scan_token.entity.ViewWalletInMonthKey;

@Repository
public interface ViewWalletInMonthRepository extends JpaRepository<ViewWalletInMonth, ViewWalletInMonthKey> {

    List<ViewWalletInMonth> findAllByIdGeckoid(String geckoid);

}
