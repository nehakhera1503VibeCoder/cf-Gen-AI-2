package com.example.starter.api.dto;

import java.math.BigDecimal;
import java.util.List;

public record CashflowScheduleResponseDto(
    BigDecimal principal,
    BigDecimal annualInterestRate,
    int periodsPerYear,
    int numberOfPeriods,
    List<CashflowPeriodDto> periods) {
}
