package com.example.starter.api;

import com.example.starter.api.dto.ErrorResponseDto;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class ApiExceptionHandler {

  @ExceptionHandler(IllegalArgumentException.class)
  public ResponseEntity<ErrorResponseDto> handleIllegalArgument(IllegalArgumentException ex) {
    return ResponseEntity.badRequest().body(new ErrorResponseDto(ex.getMessage()));
  }
}
