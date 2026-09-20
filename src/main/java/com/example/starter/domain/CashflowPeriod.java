package com.example.starter.domain;

import java.math.BigDecimal;

public record CashflowPeriod(
    int periodNumber,
    BigDecimal payment,
    BigDecimal interest,
    BigDecimal principal,
    BigDecimal remainingBalance) {
}
