package com.example.starter.api;

import static org.assertj.core.api.Assertions.assertThat;

import com.example.starter.api.dto.CashflowScheduleRequestDto;
import com.example.starter.api.dto.CashflowScheduleResponseDto;
import com.example.starter.api.dto.ErrorResponseDto;
import java.math.BigDecimal;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.ResponseEntity;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class CashflowApiIntegrationTest {

  @Autowired private TestRestTemplate restTemplate;

  @LocalServerPort private int port;

  private String url(String path) {
    return "http://localhost:" + port + path;
  }

  @Test
  void fixedSchedule_singlePeriod_returnsIndependentlyHandComputedInterestAndPrincipal() {
    // Expected values derived independently from FR-1's definition (annuity formula
    // collapses at n=1 to payment = principal * (1 + periodicRate)), not copied from
    // CashflowScheduleGeneratorImpl's source.
    var request =
        new CashflowScheduleRequestDto(new BigDecimal("1000"), new BigDecimal("0.12"), 12, 1);

    ResponseEntity<CashflowScheduleResponseDto> response =
        restTemplate.postForEntity(
            url("/api/v1/cashflows/fixed-schedule"), request, CashflowScheduleResponseDto.class);

    assertThat(response.getStatusCode().value()).isEqualTo(200);
    var body = response.getBody();
    assertThat(body).isNotNull();
    assertThat(body.periods()).hasSize(1);
    assertThat(body.periods().get(0).interest()).isEqualByComparingTo("10.00");
    assertThat(body.periods().get(0).principal()).isEqualByComparingTo("1000.00");
  }

  @Test
  void fixedSchedule_multiPeriod_principalComponentsSumToRequestedPrincipal() {
    // Independently-derivable invariant (FR-1): a fully-amortizing schedule's principal
    // components must sum to the requested principal and end at a zero balance.
    var request =
        new CashflowScheduleRequestDto(new BigDecimal("5000"), new BigDecimal("0.09"), 12, 6);

    ResponseEntity<CashflowScheduleResponseDto> response =
        restTemplate.postForEntity(
            url("/api/v1/cashflows/fixed-schedule"), request, CashflowScheduleResponseDto.class);

    assertThat(response.getStatusCode().value()).isEqualTo(200);
    var body = response.getBody();
    assertThat(body).isNotNull();

    BigDecimal totalPrincipal =
        body.periods().stream()
            .map(p -> p.principal())
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    assertThat(totalPrincipal).isEqualByComparingTo("5000.00");
    assertThat(body.periods().get(body.periods().size() - 1).remainingBalance())
        .isEqualByComparingTo("0.00");
  }

  @Test
  void fixedSchedule_nonPositivePrincipal_returns400() {
    var request = new CashflowScheduleRequestDto(BigDecimal.ZERO, new BigDecimal("0.1"), 12, 6);

    ResponseEntity<ErrorResponseDto> response =
        restTemplate.postForEntity(
            url("/api/v1/cashflows/fixed-schedule"), request, ErrorResponseDto.class);

    assertThat(response.getStatusCode().value()).isEqualTo(400);
  }

  @Test
  void fixedSchedule_missingPeriodsPerYear_returns400() {
    var request = new CashflowScheduleRequestDto(new BigDecimal("1000"), new BigDecimal("0.1"), null, 6);

    ResponseEntity<ErrorResponseDto> response =
        restTemplate.postForEntity(
            url("/api/v1/cashflows/fixed-schedule"), request, ErrorResponseDto.class);

    assertThat(response.getStatusCode().value()).isEqualTo(400);
  }
}
