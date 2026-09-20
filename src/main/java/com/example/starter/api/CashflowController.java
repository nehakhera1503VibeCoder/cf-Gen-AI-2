package com.example.starter.api;

import com.example.starter.api.dto.CashflowPeriodDto;
import com.example.starter.api.dto.CashflowScheduleRequestDto;
import com.example.starter.api.dto.CashflowScheduleResponseDto;
import com.example.starter.domain.CashflowSchedule;
import com.example.starter.service.CashflowScheduleGenerator;
import java.util.List;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class CashflowController {

  private final CashflowScheduleGenerator generator;

  public CashflowController(CashflowScheduleGenerator generator) {
    this.generator = generator;
  }

  @PostMapping("/api/v1/cashflows/fixed-schedule")
  public CashflowScheduleResponseDto generateFixedSchedule(
      @RequestBody CashflowScheduleRequestDto request) {
    CashflowSchedule schedule =
        generator.generate(
            request.principal(),
            request.annualInterestRate(),
            request.periodsPerYear(),
            request.numberOfPeriods());

    List<CashflowPeriodDto> periods =
        schedule.periods().stream()
            .map(
                p ->
                    new CashflowPeriodDto(
                        p.periodNumber(), p.payment(), p.interest(), p.principal(), p.remainingBalance()))
            .toList();

    return new CashflowScheduleResponseDto(
        schedule.principal(),
        schedule.annualInterestRate(),
        schedule.periodsPerYear(),
        schedule.numberOfPeriods(),
        periods);
  }
}
