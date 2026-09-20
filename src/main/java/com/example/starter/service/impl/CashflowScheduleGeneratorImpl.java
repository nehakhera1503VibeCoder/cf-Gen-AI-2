package com.example.starter.service.impl;

import com.example.starter.domain.CashflowPeriod;
import com.example.starter.domain.CashflowSchedule;
import com.example.starter.service.CashflowScheduleGenerator;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class CashflowScheduleGeneratorImpl implements CashflowScheduleGenerator {

  @Override
  public CashflowSchedule generate(
      BigDecimal principal, BigDecimal annualInterestRate, Integer periodsPerYear, Integer numberOfPeriods) {
    if (principal == null || principal.compareTo(BigDecimal.ZERO) <= 0) {
      throw new IllegalArgumentException("principal must be positive");
    }
    if (annualInterestRate == null || annualInterestRate.compareTo(BigDecimal.ZERO) < 0) {
      throw new IllegalArgumentException("annualInterestRate must not be negative");
    }
    if (periodsPerYear == null || periodsPerYear <= 0) {
      throw new IllegalArgumentException("periodsPerYear must be positive");
    }
    if (numberOfPeriods == null || numberOfPeriods <= 0) {
      throw new IllegalArgumentException("numberOfPeriods must be positive");
    }

    double periodicRate = annualInterestRate.doubleValue() / periodsPerYear;
    double paymentRaw =
        periodicRate == 0.0
            ? principal.doubleValue() / numberOfPeriods
            : principal.doubleValue()
                * periodicRate
                / (1 - Math.pow(1 + periodicRate, -numberOfPeriods));
    BigDecimal payment = BigDecimal.valueOf(paymentRaw).setScale(2, RoundingMode.HALF_UP);
    BigDecimal rate = BigDecimal.valueOf(periodicRate);

    List<CashflowPeriod> periods = new ArrayList<>();
    BigDecimal balance = principal.setScale(2, RoundingMode.HALF_UP);

    for (int periodNumber = 1; periodNumber <= numberOfPeriods; periodNumber++) {
      BigDecimal interest = balance.multiply(rate).setScale(2, RoundingMode.HALF_UP);
      // Last period pays off the exact remaining balance, correcting any rounding
      // drift accumulated from the level payment across prior periods (DES-001).
      BigDecimal principalComponent =
          periodNumber == numberOfPeriods
              ? balance
              : payment.subtract(interest).setScale(2, RoundingMode.HALF_UP);
      balance = balance.subtract(principalComponent).setScale(2, RoundingMode.HALF_UP);
      BigDecimal actualPayment = interest.add(principalComponent).setScale(2, RoundingMode.HALF_UP);
      periods.add(
          new CashflowPeriod(periodNumber, actualPayment, interest, principalComponent, balance));
    }

    return new CashflowSchedule(principal, annualInterestRate, periodsPerYear, numberOfPeriods, periods);
  }
}
