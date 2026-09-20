package com.example.starter.api.dto;

import java.math.BigDecimal;

public record CashflowPeriodDto(
    int periodNumber,
    BigDecimal payment,
    BigDecimal interest,
    BigDecimal principal,
    BigDecimal remainingBalance) {
}
