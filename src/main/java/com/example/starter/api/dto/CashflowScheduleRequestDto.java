package com.example.starter.api.dto;

import java.math.BigDecimal;

public record CashflowScheduleRequestDto(
    BigDecimal principal, BigDecimal annualInterestRate, Integer periodsPerYear, Integer numberOfPeriods) {
}
