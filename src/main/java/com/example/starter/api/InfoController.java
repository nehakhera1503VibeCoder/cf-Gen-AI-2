package com.example.starter.api;

import com.example.starter.api.dto.InfoResponseDto;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class InfoController {

  private final String appName;
  private final String appVersion;

  public InfoController(
      @Value("${spring.application.name}") String appName,
      @Value("${app.version}") String appVersion) {
    this.appName = appName;
    this.appVersion = appVersion;
  }

  @GetMapping("/api/v1/info")
  public InfoResponseDto info() {
    return new InfoResponseDto(appName, appVersion, "UP");
  }
}
