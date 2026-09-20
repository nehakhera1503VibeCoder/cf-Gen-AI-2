package com.example.starter.service;

import com.example.starter.domain.CashflowSchedule;
import java.math.BigDecimal;

public interface CashflowScheduleGenerator {

  /**
   * Generates a fully-amortizing, level-payment cashflow schedule (FR-1).
   *
   * @throws IllegalArgumentException if any argument is missing or out of range (FR-2)
   */
  CashflowSchedule generate(
      BigDecimal principal, BigDecimal annualInterestRate, Integer periodsPerYear, Integer numberOfPeriods);
}
