package com.homework4.SecureApp;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;
import org.springframework.stereotype.Repository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

// --- 1. ENTITY ---
@Entity
class CompanyAnnouncement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String title;
    private String content;
    private LocalDateTime postedAt;

    public CompanyAnnouncement() {}
    public CompanyAnnouncement(String title, String content) {
        this.title = title;
        this.content = content;
        this.postedAt = LocalDateTime.now();
    }
    
    // Getters
    public Long getId() { return id; }
    public String getTitle() { return title; }
    public String getContent() { return content; }
    public LocalDateTime getPostedAt() { return postedAt; }
}

// --- 2. REPOSITORY ---
@Repository
interface CompanyAnnouncementRepository extends JpaRepository<CompanyAnnouncement, Long> {}

// --- 3. CONTROLLER ---
@RestController
@RequestMapping("/api/announcements")
class CompanyAnnouncementController {

    @Autowired
    private CompanyAnnouncementRepository repository;

    // Visible to EVERYONE (Authenticated)
    @GetMapping
    public List<CompanyAnnouncement> getAll() {
        return repository.findAll();
    }

    // --- POLICY ENFORCEMENT POINT (PEP) ---
    // "Full Implementation" Mode: The App asks Keycloak explicitly.
    // The @PreAuthorize invokes our custom enforcer bean.
    
    @DeleteMapping("/{id}")
    @PreAuthorize("@policyEnforcer.hasPermission(authentication, 'Announcements', 'DELETE')") 
    public String delete(@PathVariable Long id) {
        repository.deleteById(id);
        return "Announcement deleted successfully.";
    }
}

// --- 4. DATA SEEDER ---
@Configuration
class DataSeeder {
    @Bean
    CommandLineRunner initDatabase(CompanyAnnouncementRepository repo) {
        return args -> {
            if (repo.count() == 0) {
                repo.save(new CompanyAnnouncement("Welcome", "Benvenuti nella nuova Secure App!"));
                repo.save(new CompanyAnnouncement("Maintenance", "Stasera manutenzione server dalle 22."));
                repo.save(new CompanyAnnouncement("Policy Update", "Ricordate di cambiare password ogni 30 giorni."));
            }
        };
    }
}

// --- 5. KEYCLOAK POLICY ENFORCER SERVICE ---
@org.springframework.stereotype.Service("policyEnforcer")
class KeycloakEnforcerService {

    @Value("${spring.security.oauth2.client.registration.keycloak.client-id}")
    private String clientId;

    @Value("${spring.security.oauth2.client.registration.keycloak.client-secret}")
    private String clientSecret;

    @Autowired
    private org.springframework.security.oauth2.client.OAuth2AuthorizedClientService authorizedClientService;

    // Use localhost (mapped via extra_hosts) to match Token Issuer (KC_HOSTNAME=localhost)
    private String authServerUrl = "http://localhost:8081"; 

    public boolean hasPermission(Authentication authentication, String resourceName, String scope) {
        if (!(authentication.getPrincipal() instanceof OidcUser oidcUser)) {
            return false;
        }

        try {
            // Configure AuthzClient manually
            org.keycloak.authorization.client.Configuration config = 
                new org.keycloak.authorization.client.Configuration(
                    authServerUrl, 
                    "Homework4", 
                    clientId, 
                    java.util.Collections.singletonMap("secret", clientSecret), 
                    null
                );
            
            org.keycloak.authorization.client.AuthzClient authzClient = 
                org.keycloak.authorization.client.AuthzClient.create(config);

            // 1. Get the User's ACCESS TOKEN (Not ID Token, as PEP expects Access Token)
            org.springframework.security.oauth2.client.OAuth2AuthorizedClient authorizedClient = 
                authorizedClientService.loadAuthorizedClient("keycloak", authentication.getName());
            
            if (authorizedClient == null) {
                 return false; 
            }
            
            String userAccessToken = authorizedClient.getAccessToken().getTokenValue();
            
            // 2. Prepare the Permission Request with RESOURCE ID
            String resourceId = null;
            
            // Name Mapping (Code -> Keycloak)
            // Ensures code remains decoupled from specific Keycloak naming conventions
            String lookupName = resourceName;
            if ("Announcements".equals(resourceName)) {
                lookupName = "Avvisi";
            }

            try {
                // Dynamic Lookup via Protection API (Requires reachable Keycloak)
                org.keycloak.representations.idm.authorization.ResourceRepresentation res = 
                    authzClient.protection().resource().findByName(lookupName);
                
                if (res != null) {
                    resourceId = res.getId();
                }
            } catch (Exception e) {
                // Ignore lookup failure, will result in deny
            }

            if (resourceId == null) {
                 return false;
            }
            
            org.keycloak.representations.idm.authorization.AuthorizationRequest request = 
                new org.keycloak.representations.idm.authorization.AuthorizationRequest();
            
            if (scope != null && !scope.isEmpty()) {
                request.addPermission(resourceId, scope);
            } else {
                request.addPermission(resourceId);
            }
            
            // 3. Ask Keycloak!
            authzClient.authorization(userAccessToken).authorize(request).getToken();

            return true;

        } catch (Exception e) {
            return false;
        }
    }
}
