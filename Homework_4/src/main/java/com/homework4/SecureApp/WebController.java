package com.homework4.SecureApp;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import org.springframework.security.access.prepost.PreAuthorize; // Added

import org.springframework.beans.factory.annotation.Autowired; // Added
import java.util.List; // Added

@RestController
public class WebController {

    @Autowired
    private CompanyAnnouncementRepository repository;

    @GetMapping("/")
    public String home() {
        return "<h1>Welcome to the Public Homepage</h1><a href='/private'>Go to Private</a> | <a href='/admin'>Go to Admin</a>";
    }

    @GetMapping("/private")
    public String privatePage(@AuthenticationPrincipal OidcUser principal, jakarta.servlet.http.HttpServletRequest request) {
        org.springframework.security.web.csrf.CsrfToken csrf = (org.springframework.security.web.csrf.CsrfToken) request.getAttribute(org.springframework.security.web.csrf.CsrfToken.class.getName());
        return "<html><head><meta name='_csrf' content='" + csrf.getToken() + "'/><meta name='_csrf_header' content='" + csrf.getHeaderName() + "'/></head><body>" +
               "<h1>Private Page</h1><p>Welcome, " + principal.getFullName() + "</p>" +
               "<p>Your Roles: " + principal.getAuthorities() + "</p>" +
               "<form action='/logout' method='post'><input type='hidden' name='" + csrf.getParameterName() + "' value='" + csrf.getToken() + "'/><button type='submit'>Logout</button></form>" +
               "<h2>Latest Announcements</h2>" + renderAnnouncements() + "</body></html>";
    }

    // --- POLICY ENFORCEMENT POINT (PEP) ---
    @GetMapping("/admin")
    @PreAuthorize("@policyEnforcer.hasPermission(authentication, 'AdminResource', '')")
    public String adminPage(@AuthenticationPrincipal OidcUser principal, jakarta.servlet.http.HttpServletRequest request) {
        org.springframework.security.web.csrf.CsrfToken csrf = (org.springframework.security.web.csrf.CsrfToken) request.getAttribute(org.springframework.security.web.csrf.CsrfToken.class.getName());
        return "<html><head><meta name='_csrf' content='" + csrf.getToken() + "'/><meta name='_csrf_header' content='" + csrf.getHeaderName() + "'/></head><body>" +
               "<h1>ADMIN DASHBOARD</h1><p>WARNING: Restricted Area</p>" +
               "<p>Welcome SuperUser: " + principal.getPreferredUsername() + "</p>" +
               "<form action='/logout' method='post'><input type='hidden' name='" + csrf.getParameterName() + "' value='" + csrf.getToken() + "'/><button type='submit'>Logout</button></form>" +
               "<h2>Manage Announcements</h2>" + renderAnnouncements() + "</body></html>";
    }

    private String renderAnnouncements() {
        List<CompanyAnnouncement> list = repository.findAll();
        StringBuilder sb = new StringBuilder("<ul>");
        for (CompanyAnnouncement a : list) {
            sb.append("<li><b>").append(a.getTitle()).append("</b>: ").append(a.getContent())
              .append(" <button onclick=\"const token = document.querySelector('meta[name=_csrf]').content; const header = document.querySelector('meta[name=_csrf_header]').content; fetch('/api/announcements/").append(a.getId())
              .append("', {method: 'DELETE', headers: {[header]: token}}).then(r => { if(r.ok) alert('Deleted!'); else alert('Start Running! KEYCLOAK POLICE IS HERE 🚨 (403 Forbidden)'); location.reload(); })\">❌ Delete</button>")
              .append("</li>");
        }
        sb.append("</ul>");
        return sb.toString();
    }
}
