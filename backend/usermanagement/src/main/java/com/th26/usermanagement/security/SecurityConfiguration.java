package com.th26.usermanagement.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.SecurityFilterChain;

import com.th26.usermanagement.exceptions.UserNotFoundException;

@Configuration
public class SecurityConfiguration {
    // Empty to disable default security configuration
    @Bean
    public UserDetailsService userDetailsService() {
        return username -> {
            throw new UserNotFoundException("No users configured");
        };
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http.authorizeHttpRequests(auth -> auth.anyRequest().permitAll())
            .csrf(csrf -> csrf.disable());
        return http.build();
    }
}
