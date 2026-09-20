package com.example.starter.domain;

import java.math.BigDecimal;
import java.util.List;

public record CashflowSchedule(
    BigDecimal principal,
    BigDecimal annualInterestRate,
    int periodsPerYear,
    int numberOfPeriods,
    List<CashflowPeriod> periods) {
}
