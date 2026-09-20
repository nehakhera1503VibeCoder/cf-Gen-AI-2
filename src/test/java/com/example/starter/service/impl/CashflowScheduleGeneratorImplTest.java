package com.example.starter.service.impl;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.example.starter.domain.CashflowPeriod;
import com.example.starter.domain.CashflowSchedule;
import java.math.BigDecimal;
import java.util.List;
import org.junit.jupiter.api.Test;

class CashflowScheduleGeneratorImplTest {

  private final CashflowScheduleGeneratorImpl generator = new CashflowScheduleGeneratorImpl();

  @Test
  void singlePeriod_computesInterestAndPrincipalExactly() {
    // Hand-computed: for n=1 the annuity formula collapses to payment = principal * (1 + i).
    CashflowSchedule schedule =
        generator.generate(new BigDecimal("1000"), new BigDecimal("0.12"), 12, 1);

    assertThat(schedule.periods()).hasSize(1);
    CashflowPeriod period = schedule.periods().get(0);
    assertThat(period.interest()).isEqualByComparingTo("10.00");
    assertThat(period.principal()).isEqualByComparingTo("1000.00");
    assertThat(period.payment()).isEqualByComparingTo("1010.00");
    assertThat(period.remainingBalance()).isEqualByComparingTo("0.00");
  }

  @Test
  void zeroRate_distributesPrincipalEvenlyAcrossPeriods() {
    // Hand-computed: at a 0% rate, each of 3 periods repays exactly principal / 3.
    CashflowSchedule schedule = generator.generate(new BigDecimal("300"), BigDecimal.ZERO, 12, 3);

    List<CashflowPeriod> periods = schedule.periods();
    assertThat(periods).hasSize(3);
    assertThat(periods.get(0).principal()).isEqualByComparingTo("100.00");
    assertThat(periods.get(0).remainingBalance()).isEqualByComparingTo("200.00");
    assertThat(periods.get(1).remainingBalance()).isEqualByComparingTo("100.00");
    assertThat(periods.get(2).remainingBalance()).isEqualByComparingTo("0.00");
    periods.forEach(p -> assertThat(p.interest()).isEqualByComparingTo("0.00"));
  }

  @Test
  void multiPeriod_principalComponentsSumToOriginalPrincipalAndBalanceReachesZero() {
    // Independently-derivable invariant for ANY fully-amortizing schedule, regardless of
    // rounding: total principal repaid must equal the original principal, and the final
    // period must reach a zero balance.
    CashflowSchedule schedule =
        generator.generate(new BigDecimal("5000"), new BigDecimal("0.09"), 12, 6);

    BigDecimal totalPrincipal =
        schedule.periods().stream()
            .map(CashflowPeriod::principal)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

    assertThat(totalPrincipal).isEqualByComparingTo("5000.00");
    assertThat(schedule.periods().get(5).remainingBalance()).isEqualByComparingTo("0.00");
  }

  @Test
  void rejectsNonPositivePrincipal() {
    assertThatThrownBy(() -> generator.generate(BigDecimal.ZERO, new BigDecimal("0.1"), 12, 6))
        .isInstanceOf(IllegalArgumentException.class);
  }

  @Test
  void rejectsNegativeRate() {
    assertThatThrownBy(
            () -> generator.generate(new BigDecimal("1000"), new BigDecimal("-0.01"), 12, 6))
        .isInstanceOf(IllegalArgumentException.class);
  }

  @Test
  void rejectsNonPositivePeriods() {
    assertThatThrownBy(
            () -> generator.generate(new BigDecimal("1000"), new BigDecimal("0.1"), 12, 0))
        .isInstanceOf(IllegalArgumentException.class);
  }

  @Test
  void rejectsMissingPeriodsPerYear() {
    assertThatThrownBy(
            () -> generator.generate(new BigDecimal("1000"), new BigDecimal("0.1"), null, 6))
        .isInstanceOf(IllegalArgumentException.class);
  }
}
