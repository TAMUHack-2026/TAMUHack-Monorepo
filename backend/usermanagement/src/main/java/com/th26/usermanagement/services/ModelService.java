package com.th26.usermanagement.services;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;

import java.math.BigDecimal;
import java.util.List;

public interface ModelService {
    ResponseEntity<String> runInference(String email, List<BigDecimal> inputData) throws MethodArgumentNotValidException;
}
