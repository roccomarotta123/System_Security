package com.homework4.SecureApp;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.security.oauth2.client.oidc.web.logout.OidcClientInitiatedLogoutSuccessHandler;
import org.springframework.security.web.authentication.logout.LogoutSuccessHandler;
import org.springframework.security.web.authentication.logout.SimpleUrlLogoutSuccessHandler;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.core.OAuth2TokenValidator;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtValidators;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity // ANNOTATION ADDED
public class SecurityConfig {

    @Autowired
    private org.springframework.security.oauth2.client.registration.ClientRegistrationRepository clientRegistrationRepository;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/", "/public").permitAll()
                // .requestMatchers("/admin/**").hasRole("admin") // REMOVED: Managed by Keycloak PEP (WebController)
                .anyRequest().authenticated()
            )
            .oauth2Login(oauth2 -> {
                // Default configuration is enough for authentication
            })
            .logout(logout -> logout
                .logoutSuccessHandler(oidcLogoutSuccessHandler())
                .invalidateHttpSession(true)
                .clearAuthentication(true)
                .deleteCookies("JSESSIONID")
            );
        return http.build();
    }

    private org.springframework.security.web.authentication.logout.LogoutSuccessHandler oidcLogoutSuccessHandler() {
        return (request, response, authentication) -> {
            String logoutUrl = "http://localhost:8081/realms/Homework4/protocol/openid-connect/logout";
            
            if (authentication != null && authentication.getPrincipal() instanceof org.springframework.security.oauth2.core.oidc.user.OidcUser) {
                org.springframework.security.oauth2.core.oidc.user.OidcUser oidcUser = (org.springframework.security.oauth2.core.oidc.user.OidcUser) authentication.getPrincipal();
                // Append id_token_hint to ensure seamless logout
                logoutUrl += "?id_token_hint=" + oidcUser.getIdToken().getTokenValue();
                logoutUrl += "&post_logout_redirect_uri=https://localhost:8443";
            } else {
                // Fallback if no OIDC session (shouldn't happen in authenticated context)
                logoutUrl += "?post_logout_redirect_uri=https://localhost:8443";
            }

            response.sendRedirect(logoutUrl);
        };
    }

    // Custom JWT Decoder to support "Hybrid" Strategy
    // Accepts tokens with "iss": "http://localhost:8081..." even though we talk to "http://sys-sec-keycloak:8080..."
    @Bean
    public org.springframework.security.oauth2.jwt.JwtDecoder jwtDecoder() {
        String issuerUri = "http://sys-sec-keycloak:8080/realms/Homework4"; // Start with internal URI
        // We use the internal URI to fetch the JWK Set (Public Keys) - This never fails
        org.springframework.security.oauth2.jwt.NimbusJwtDecoder jwtDecoder = org.springframework.security.oauth2.jwt.NimbusJwtDecoder.withJwkSetUri(issuerUri + "/protocol/openid-connect/certs").build();
        
        // We override the validator to accept 'localhost' as a valid issuer
        org.springframework.security.oauth2.core.OAuth2TokenValidator<org.springframework.security.oauth2.jwt.Jwt> withIssuer = org.springframework.security.oauth2.jwt.JwtValidators.createDefaultWithIssuer("http://localhost:8081/realms/Homework4");
        jwtDecoder.setJwtValidator(withIssuer);
        
        return jwtDecoder;
    }
}
