package com.th26.usermanagement.exceptions;

import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.http.HttpStatus;

@ResponseStatus(HttpStatus.CONFLICT)
public class UserExistsException extends IllegalArgumentException {
    public UserExistsException(String message) {
        super(message);
    }
}
