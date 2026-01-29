package com.th26.usermanagement.exceptions;

import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.http.HttpStatus;

@ResponseStatus(HttpStatus.BAD_GATEWAY)
public class GatewayException extends RuntimeException {
    public GatewayException(String message) {
        super(message);
    }
}
