package com.example.starter.api;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.ResponseEntity;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class InfoControllerTest {

  @Autowired private TestRestTemplate restTemplate;

  @LocalServerPort private int port;

  @Test
  void info_returnsNameVersionAndUpStatus() {
    // Expected values derived independently from the requirement
    // (FR-1/NFR-1: name is the artifactId, version is the pom version),
    // not copied from InfoController's implementation.
    String expectedName = "ai-native-spring-starter";
    String expectedVersion = "0.1.0-SNAPSHOT";

    ResponseEntity<InfoResponse> response =
        restTemplate.getForEntity(
            "http://localhost:" + port + "/api/v1/info", InfoResponse.class);

    assertThat(response.getStatusCode().value()).isEqualTo(200);
    assertThat(response.getBody()).isNotNull();
    assertThat(response.getBody().name()).isEqualTo(expectedName);
    assertThat(response.getBody().version()).isEqualTo(expectedVersion);
    assertThat(response.getBody().status()).isEqualTo("UP");
  }

  private record InfoResponse(String name, String version, String status) {}
}
